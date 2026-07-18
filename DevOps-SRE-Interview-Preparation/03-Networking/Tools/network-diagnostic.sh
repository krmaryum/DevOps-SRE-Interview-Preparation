#!/usr/bin/env bash

# Network Diagnostic Tool
# Read-only checks for local context, resolution, ICMP, ports, and HTTP(S).
# Exit codes: 0=required checks passed, 1=runtime error, 2=usage error,
#             3=warnings only, 4=one or more required checks failed.

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly VERSION="1.0.0"

HOST=""
PORT=""
PROTOCOL="tcp"
URL=""
TIMEOUT_SECONDS=5
LOG_FILE=""
QUIET=false
WARNINGS=0
FAILURES=0

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME -H HOST [options]

Options:
  -H HOST       Required destination hostname or IP address
  -p PORT       Destination port to test
  -P PROTOCOL   tcp or udp (default: tcp)
  -u URL        Optional HTTP/HTTPS URL to request
  -t SECONDS    Per-check timeout, 1-60 (default: 5)
  -o FILE       Append output to a log file
  -q            Quiet; write only to optional log
  -V            Show version
  -h            Show help

Exit codes:
  0  Required checks passed
  1  Runtime/dependency error
  2  Invalid usage/input
  3  Required checks passed with warnings
  4  One or more required checks failed
EOF
}

error() {
    printf '%s: error: %s\n' "$SCRIPT_NAME" "$*" >&2
}

emit() {
    local line="$*"
    [[ "$QUIET" == true ]] || printf '%s\n' "$line"
    [[ -z "$LOG_FILE" ]] || printf '%s\n' "$line" >> "$LOG_FILE"
}

pass() {
    emit "PASS  $*"
}

warn() {
    ((WARNINGS += 1))
    emit "WARN  $*"
}

fail() {
    ((FAILURES += 1))
    emit "FAIL  $*"
}

require_command() {
    local command_name="$1"
    command -v "$command_name" >/dev/null 2>&1 || {
        error "required command not found: $command_name"
        return 1
    }
}

validate_inputs() {
    if [[ -z "$HOST" ]]; then
        error "-H HOST is required"
        return 2
    fi

    if [[ -n "$PORT" ]] && { [[ ! "$PORT" =~ ^[0-9]+$ ]] || ((PORT < 1 || PORT > 65535)); }; then
        error "port must be an integer from 1 to 65535"
        return 2
    fi

    if [[ "$PROTOCOL" != tcp && "$PROTOCOL" != udp ]]; then
        error "protocol must be tcp or udp"
        return 2
    fi

    if [[ ! "$TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || ((TIMEOUT_SECONDS < 1 || TIMEOUT_SECONDS > 60)); then
        error "timeout must be an integer from 1 to 60"
        return 2
    fi

    if [[ -n "$URL" && ! "$URL" =~ ^https?:// ]]; then
        error "URL must begin with http:// or https://"
        return 2
    fi
}

prepare_log() {
    local parent
    [[ -n "$LOG_FILE" ]] || return 0

    parent="${LOG_FILE%/*}"
    [[ "$parent" == "$LOG_FILE" ]] && parent="."

    [[ -d "$parent" ]] || {
        error "log directory does not exist: $parent"
        return 1
    }

    [[ ! -e "$LOG_FILE" || -f "$LOG_FILE" ]] || {
        error "log target is not a regular file: $LOG_FILE"
        return 1
    }

    : >> "$LOG_FILE" || {
        error "cannot write log file: $LOG_FILE"
        return 1
    }
}

show_local_context() {
    emit "============================================================"
    emit "Network Diagnostic Report"
    emit "timestamp=$(date --iso-8601=seconds)"
    emit "source_host=$(hostname)"
    emit "destination=$HOST"
    emit "protocol=$PROTOCOL port=${PORT:-not-requested}"

    if command -v ip >/dev/null 2>&1; then
        emit "-- local addresses --"
        while IFS= read -r line; do emit "$line"; done < <(ip -br address 2>/dev/null || true)
        emit "-- selected route --"
        local route
        route="$(ip route get "$HOST" 2>/dev/null | head -n 1 || true)"
        [[ -n "$route" ]] && emit "$route" || warn "route lookup unavailable for $HOST"
    else
        warn "ip command unavailable; local address and route context skipped"
    fi
    emit "============================================================"
}

check_resolution() {
    local resolution
    resolution="$(getent ahosts "$HOST" 2>/dev/null | awk '!seen[$1]++ {print $1}' | paste -sd ',' -)"

    if [[ -n "$resolution" ]]; then
        pass "resolution host=$HOST addresses=$resolution"
    else
        fail "resolution failed for $HOST"
        return
    fi

    if command -v dig >/dev/null 2>&1; then
        local dns_result
        dns_result="$(dig +time="$TIMEOUT_SECONDS" +tries=1 +short "$HOST" 2>/dev/null | paste -sd ',' -)"
        [[ -n "$dns_result" ]] && pass "dns-detail answers=$dns_result" || warn "dig returned no direct A/AAAA-style answer"
    else
        warn "dig unavailable; DNS-specific detail skipped"
    fi
}

check_icmp() {
    if ! command -v ping >/dev/null 2>&1; then
        warn "ping unavailable; ICMP check skipped"
        return
    fi

    if ping -c 1 -W "$TIMEOUT_SECONDS" "$HOST" >/dev/null 2>&1; then
        pass "ICMP echo reply received"
    else
        warn "ICMP echo failed or filtered; application connectivity may still work"
    fi
}

check_tcp_port() {
    [[ -n "$PORT" ]] || return 0

    if command -v nc >/dev/null 2>&1; then
        if nc -z -w "$TIMEOUT_SECONDS" "$HOST" "$PORT" >/dev/null 2>&1; then
            pass "tcp connection host=$HOST port=$PORT"
        else
            fail "tcp connection failed host=$HOST port=$PORT"
        fi
    elif command -v timeout >/dev/null 2>&1; then
        if timeout "$TIMEOUT_SECONDS" bash -c 'exec 3<>"/dev/tcp/$1/$2"' bash "$HOST" "$PORT" 2>/dev/null; then
            pass "tcp connection host=$HOST port=$PORT"
        else
            fail "tcp connection failed host=$HOST port=$PORT"
        fi
    else
        error "nc or timeout is required for a TCP port test"
        return 1
    fi
}

check_udp_port() {
    [[ -n "$PORT" ]] || return 0

    if ! command -v nc >/dev/null 2>&1; then
        warn "nc unavailable; UDP probe skipped"
        return
    fi

    if nc -z -u -w "$TIMEOUT_SECONDS" "$HOST" "$PORT" >/dev/null 2>&1; then
        pass "UDP probe sent host=$HOST port=$PORT"
    else
        warn "UDP probe was not confirmed; UDP silence does not prove the service is down"
    fi
}

check_url() {
    [[ -n "$URL" ]] || return 0

    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required for URL testing"
        return 1
    fi

    local http_code
    if http_code="$(curl --connect-timeout "$TIMEOUT_SECONDS" --max-time "$((TIMEOUT_SECONDS * 2))" -sS -o /dev/null -w '%{http_code}' "$URL")"; then
        if [[ "$http_code" =~ ^[23] ]]; then
            pass "HTTP request url=$URL status=$http_code"
        else
            fail "HTTP request url=$URL status=$http_code"
        fi
    else
        fail "HTTP request failed url=$URL"
    fi
}

parse_options() {
    local option
    while getopts ':H:p:P:u:t:o:qVh' option; do
        case "$option" in
            H) HOST="$OPTARG" ;;
            p) PORT="$OPTARG" ;;
            P) PROTOCOL="${OPTARG,,}" ;;
            u) URL="$OPTARG" ;;
            t) TIMEOUT_SECONDS="$OPTARG" ;;
            o) LOG_FILE="$OPTARG" ;;
            q) QUIET=true ;;
            V) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
            h) usage; exit 0 ;;
            :) error "option -$OPTARG requires an argument"; usage >&2; exit 2 ;;
            \?) error "unknown option: -$OPTARG"; usage >&2; exit 2 ;;
        esac
    done
    shift "$((OPTIND - 1))"
    (($# == 0)) || { error "unexpected argument: $1"; return 2; }
}

main() {
    parse_options "$@"
    validate_inputs
    prepare_log
    require_command awk
    require_command date
    require_command getent
    require_command hostname
    require_command paste

    show_local_context
    check_resolution
    check_icmp

    if [[ "$PROTOCOL" == tcp ]]; then
        check_tcp_port
    else
        check_udp_port
    fi

    check_url
    emit "============================================================"
    emit "warnings=$WARNINGS failures=$FAILURES"

    if ((FAILURES > 0)); then
        return 4
    elif ((WARNINGS > 0)); then
        return 3
    fi
    return 0
}

main "$@"


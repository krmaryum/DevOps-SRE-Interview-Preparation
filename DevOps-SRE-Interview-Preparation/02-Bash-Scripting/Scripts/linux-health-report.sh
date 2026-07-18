#!/usr/bin/env bash

# Linux Health Report
# Collects a read-only health snapshot and returns a monitoring-friendly status.
# Exit codes: 0=healthy, 1=runtime error, 2=usage error, 3=warning detected.

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly VERSION="1.0.0"

DISK_WARNING=80
MEMORY_WARNING=85
LOAD_RATIO_WARNING="1.00"
SERVICE_LIST=""
LOG_FILE=""
QUIET=false
WARNING_COUNT=0

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Create a read-only Linux health report.

Options:
  -d PERCENT   Root filesystem warning threshold (default: 80)
  -m PERCENT   Memory warning threshold (default: 85)
  -r RATIO     1-minute load-per-CPU warning ratio (default: 1.00)
  -s LIST      Comma-separated systemd services to check
  -o FILE      Append the report to FILE
  -q           Quiet: write only to the optional log file
  -V           Show version
  -h           Show help

Exit codes:
  0  All checks healthy
  1  Runtime or dependency error
  2  Invalid option or input
  3  One or more warning thresholds exceeded
EOF
}

error() {
    printf '%s: error: %s\n' "$SCRIPT_NAME" "$*" >&2
}

emit() {
    local line="$*"

    if [[ "$QUIET" != true ]]; then
        printf '%s\n' "$line"
    fi

    if [[ -n "$LOG_FILE" ]]; then
        printf '%s\n' "$line" >> "$LOG_FILE"
    fi
}

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "required command not found: $command_name"
        return 1
    fi
}

validate_percent() {
    local name="$1"
    local value="$2"

    if [[ ! "$value" =~ ^[0-9]+$ ]] || ((value < 1 || value > 100)); then
        error "$name must be an integer from 1 to 100"
        return 1
    fi
}

validate_ratio() {
    local value="$1"

    if [[ ! "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        error "load ratio must be a positive number"
        return 1
    fi

    if ! awk -v value="$value" 'BEGIN { exit !(value > 0) }'; then
        error "load ratio must be greater than zero"
        return 1
    fi
}

prepare_log_file() {
    local parent_directory

    [[ -n "$LOG_FILE" ]] || return 0
    parent_directory="${LOG_FILE%/*}"
    [[ "$parent_directory" == "$LOG_FILE" ]] && parent_directory="."

    if [[ ! -d "$parent_directory" ]]; then
        error "log directory does not exist: $parent_directory"
        return 1
    fi

    if [[ -e "$LOG_FILE" && ! -f "$LOG_FILE" ]]; then
        error "log target is not a regular file: $LOG_FILE"
        return 1
    fi

    if ! : >> "$LOG_FILE"; then
        error "cannot write log file: $LOG_FILE"
        return 1
    fi
}

add_warning() {
    ((WARNING_COUNT += 1))
    emit "STATUS  WARNING  $*"
}

add_healthy() {
    emit "STATUS  HEALTHY  $*"
}

check_disk() {
    local usage

    usage="$(df -P / | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }')"
    if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
        error "unable to determine root filesystem utilization"
        return 1
    fi

    if ((usage >= DISK_WARNING)); then
        add_warning "root filesystem usage=${usage}% threshold=${DISK_WARNING}%"
    else
        add_healthy "root filesystem usage=${usage}% threshold=${DISK_WARNING}%"
    fi
}

check_memory() {
    local usage

    usage="$(free -m | awk '/^Mem:/ { if ($2 > 0) printf "%.0f", (($2 - $7) / $2) * 100 }')"
    if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
        error "unable to determine memory utilization"
        return 1
    fi

    if ((usage >= MEMORY_WARNING)); then
        add_warning "memory usage=${usage}% threshold=${MEMORY_WARNING}%"
    else
        add_healthy "memory usage=${usage}% threshold=${MEMORY_WARNING}%"
    fi
}

check_load() {
    local load_one cpu_count load_ratio

    read -r load_one _ < /proc/loadavg
    cpu_count="$(nproc)"
    load_ratio="$(awk -v load="$load_one" -v cpus="$cpu_count" 'BEGIN { printf "%.2f", load / cpus }')"

    if awk -v current="$load_ratio" -v warning="$LOAD_RATIO_WARNING" 'BEGIN { exit !(current >= warning) }'; then
        add_warning "load1=${load_one} cpus=${cpu_count} ratio=${load_ratio} threshold=${LOAD_RATIO_WARNING}"
    else
        add_healthy "load1=${load_one} cpus=${cpu_count} ratio=${load_ratio} threshold=${LOAD_RATIO_WARNING}"
    fi
}

check_services() {
    local service
    local -a services=()

    [[ -n "$SERVICE_LIST" ]] || return 0
    require_command systemctl || return 1

    IFS=',' read -r -a services <<< "$SERVICE_LIST"
    for service in "${services[@]}"; do
        if [[ ! "$service" =~ ^[A-Za-z0-9_.@-]+$ ]]; then
            error "invalid service name: $service"
            return 1
        fi

        if systemctl is-active --quiet "$service"; then
            add_healthy "service=$service state=active"
        else
            add_warning "service=$service state=inactive"
        fi
    done
}

show_summary() {
    local hostname_value kernel_value default_route

    hostname_value="$(hostname)"
    kernel_value="$(uname -r)"
    default_route="unavailable"

    if command -v ip >/dev/null 2>&1; then
        default_route="$(ip route show default 2>/dev/null | head -n 1 || true)"
        [[ -n "$default_route" ]] || default_route="not configured"
    fi

    emit "============================================================"
    emit "Linux Health Report"
    emit "timestamp=$(date --iso-8601=seconds)"
    emit "hostname=$hostname_value"
    emit "kernel=$kernel_value"
    emit "uptime=$(uptime -p 2>/dev/null || uptime)"
    emit "default_route=$default_route"
    emit "============================================================"
}

parse_options() {
    local option

    while getopts ':d:m:r:s:o:qVh' option; do
        case "$option" in
            d) DISK_WARNING="$OPTARG" ;;
            m) MEMORY_WARNING="$OPTARG" ;;
            r) LOAD_RATIO_WARNING="$OPTARG" ;;
            s) SERVICE_LIST="$OPTARG" ;;
            o) LOG_FILE="$OPTARG" ;;
            q) QUIET=true ;;
            V) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
            h) usage; exit 0 ;;
            :) error "option -$OPTARG requires an argument"; usage >&2; exit 2 ;;
            \?) error "unknown option: -$OPTARG"; usage >&2; exit 2 ;;
        esac
    done
    shift "$((OPTIND - 1))"

    if (($# > 0)); then
        error "unexpected positional argument: $1"
        usage >&2
        exit 2
    fi
}

main() {
    parse_options "$@"
    validate_percent "disk threshold" "$DISK_WARNING" || return 2
    validate_percent "memory threshold" "$MEMORY_WARNING" || return 2
    validate_ratio "$LOAD_RATIO_WARNING" || return 2

    require_command awk
    require_command date
    require_command df
    require_command free
    require_command hostname
    require_command nproc
    require_command uname
    require_command uptime
    prepare_log_file

    show_summary
    check_disk
    check_memory
    check_load
    check_services
    emit "============================================================"
    emit "warnings=$WARNING_COUNT"

    if ((WARNING_COUNT > 0)); then
        return 3
    fi

    return 0
}

main "$@"


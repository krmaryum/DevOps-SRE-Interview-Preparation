#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script: create-devops-sre-interview-structure.sh
# Purpose: Create the DevOps & SRE Interview Preparation repository structure.
# Usage:   bash create-devops-sre-interview-structure.sh [project-directory]
# Example: bash create-devops-sre-interview-structure.sh
#          bash create-devops-sre-interview-structure.sh My-Interview-Repo
#
# Safety:
# - Existing files are not overwritten.
# - mkdir -p safely reuses existing directories.
# - .gitkeep files ensure otherwise-empty directories are tracked by Git.
# -----------------------------------------------------------------------------

set -Eeuo pipefail

PROJECT_DIR="${1:-DevOps-SRE-Interview-Preparation}"

if [[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "/" || "$PROJECT_DIR" == "." ]]; then
    printf 'Error: Choose a specific project-directory name.\n' >&2
    exit 1
fi

directories=(
    "00-Master-Roadmap"
    "01-Linux/Study-Notes"
    "01-Linux/Hands-on-Labs"
    "01-Linux/Troubleshooting-Scenarios"
    "01-Linux/Interview-Questions"
    "01-Linux/MCQ-Quizzes"
    "01-Linux/Cheat-Sheets"
    "02-Bash-Scripting/Study-Notes"
    "02-Bash-Scripting/Scripts"
    "02-Bash-Scripting/Hands-on-Labs"
    "02-Bash-Scripting/Troubleshooting-Scenarios"
    "02-Bash-Scripting/Interview-Questions"
    "02-Bash-Scripting/MCQ-Quizzes"
    "03-Networking/Basic-Networking"
    "03-Networking/Advanced-Networking"
    "03-Networking/Hands-on-Labs"
    "03-Networking/Troubleshooting-Scenarios"
    "03-Networking/Interview-Questions"
    "04-Docker/Study-Notes"
    "04-Docker/Dockerfiles"
    "04-Docker/Docker-Compose"
    "04-Docker/Hands-on-Labs"
    "04-Docker/Troubleshooting-Scenarios"
    "04-Docker/Interview-Questions"
    "05-Kubernetes/Study-Notes"
    "05-Kubernetes/Manifests"
    "05-Kubernetes/Helm"
    "05-Kubernetes/Hands-on-Labs"
    "05-Kubernetes/Troubleshooting-Scenarios"
    "05-Kubernetes/Interview-Questions"
    "06-CI-CD/Study-Notes"
    "06-CI-CD/GitHub-Actions"
    "06-CI-CD/Jenkins"
    "06-CI-CD/Hands-on-Labs"
    "06-CI-CD/Interview-Questions"
    "07-Terraform/Study-Notes"
    "07-Terraform/Modules"
    "07-Terraform/Projects"
    "07-Terraform/Hands-on-Labs"
    "07-Terraform/Interview-Questions"
    "08-Ansible/Study-Notes"
    "08-Ansible/Playbooks"
    "08-Ansible/Roles"
    "08-Ansible/Hands-on-Labs"
    "08-Ansible/Interview-Questions"
    "09-AWS-Cloud-Services/IAM"
    "09-AWS-Cloud-Services/Networking"
    "09-AWS-Cloud-Services/Compute"
    "09-AWS-Cloud-Services/Storage"
    "09-AWS-Cloud-Services/Databases"
    "09-AWS-Cloud-Services/Monitoring"
    "09-AWS-Cloud-Services/Hands-on-Labs"
    "09-AWS-Cloud-Services/Interview-Questions"
    "10-Python-for-DevOps/Study-Notes"
    "10-Python-for-DevOps/Automation-Scripts"
    "10-Python-for-DevOps/API-Projects"
    "10-Python-for-DevOps/Hands-on-Labs"
    "10-Python-for-DevOps/Interview-Questions"
    "11-Observability/Metrics"
    "11-Observability/Logs"
    "11-Observability/Traces"
    "11-Observability/Prometheus"
    "11-Observability/Grafana"
    "11-Observability/Hands-on-Labs"
    "11-Observability/Interview-Questions"
    "12-System-Design/Architecture-Diagrams"
    "12-System-Design/Design-Questions"
    "12-System-Design/Case-Studies"
    "13-Mock-Interviews/Technical-Rounds"
    "13-Mock-Interviews/Scenario-Based-Rounds"
    "13-Mock-Interviews/Behavioral-Rounds"
    "14-Capstone-Project/Architecture"
    "14-Capstone-Project/Application"
    "14-Capstone-Project/Docker"
    "14-Capstone-Project/Kubernetes"
    "14-Capstone-Project/Terraform"
    "14-Capstone-Project/Ansible"
    "14-Capstone-Project/CI-CD"
    "14-Capstone-Project/Monitoring"
    "14-Capstone-Project/Documentation"
)

top_level_topics=(
    "01-Linux"
    "02-Bash-Scripting"
    "03-Networking"
    "04-Docker"
    "05-Kubernetes"
    "06-CI-CD"
    "07-Terraform"
    "08-Ansible"
    "09-AWS-Cloud-Services"
    "10-Python-for-DevOps"
    "11-Observability"
    "12-System-Design"
    "13-Mock-Interviews"
    "14-Capstone-Project"
)

printf 'Creating project: %s\n' "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"

for directory in "${directories[@]}"; do
    mkdir -p "$PROJECT_DIR/$directory"
done

# Git does not track empty directories. Each planned leaf directory receives
# a .gitkeep placeholder. Remove it later after adding real content.
for directory in "${directories[@]}"; do
    touch "$PROJECT_DIR/$directory/.gitkeep"
done

create_readme_if_missing() {
    local readme_path="$1"
    local heading="$2"

    if [[ ! -e "$readme_path" ]]; then
        printf '# %s\n\nContent for this section will be added during the interview-preparation project.\n' \
            "$heading" > "$readme_path"
    fi
}

create_readme_if_missing \
    "$PROJECT_DIR/README.md" \
    "DevOps & SRE Interview Preparation"

for topic in "${top_level_topics[@]}"; do
    heading="${topic#??-}"
    heading="${heading//-/ }"
    create_readme_if_missing "$PROJECT_DIR/$topic/README.md" "$heading"
done

if [[ ! -e "$PROJECT_DIR/00-Master-Roadmap/Master-Roadmap.md" ]]; then
    printf '# DevOps & SRE Interview Preparation — Master Roadmap\n\nThe detailed project roadmap will be maintained here.\n' \
        > "$PROJECT_DIR/00-Master-Roadmap/Master-Roadmap.md"
fi

if [[ ! -e "$PROJECT_DIR/13-Mock-Interviews/Progress-Tracker.md" ]]; then
    printf '# Mock Interview Progress Tracker\n\n| Date | Track | Score | Weak Areas | Next Action |\n|---|---|---:|---|---|\n' \
        > "$PROJECT_DIR/13-Mock-Interviews/Progress-Tracker.md"
fi

printf '\nRepository structure created successfully.\n'
printf 'Location: %s\n' "$PROJECT_DIR"
printf '\nNext commands:\n'
printf '  cd %q\n' "$PROJECT_DIR"
printf '  git init\n'
printf '  git add .\n'
printf '  git commit -m %q\n' "chore: initialize DevOps and SRE interview preparation structure"


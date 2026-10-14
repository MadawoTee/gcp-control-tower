#!/usr/bin/env bash
#
# run_connectivity_tests.sh
# ===========================
# Proves that stage 1-networking's dev VPC actually works:
#   1. internal DNS resolution
#   2. Cloud NAT egress to the public internet from a VM with no external IP
#
# Requires: terraform, gcloud (authenticated), and that you've already run
#   `terraform apply` inside this directory (see README.md) so the probe VM
#   from main.tf exists.
#
# Usage:
#   ./run_connectivity_tests.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PASS=0
FAIL=0
declare -a RESULTS=()

record() {
  local status="$1" desc="$2"
  if [[ "$status" == "PASS" ]]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
  RESULTS+=("$status|$desc")
}

echo "==> Reading probe VM inventory from Terraform state..."
PROBE_JSON="$(terraform output -json probe_instance)"

get_field() {
  local field="$1"
  echo "$PROBE_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['$field'])"
}

ZONE="$(get_field zone)"
PROJECT="$(get_field project)"
NAME="$(get_field name)"

ssh_cmd() {
  local cmd="$1"
  gcloud compute ssh "$NAME" \
    --project="$PROJECT" \
    --zone="$ZONE" \
    --tunnel-through-iap \
    --command="$cmd" \
    --quiet 2>/dev/null
}

echo
echo "==> 1. Internal DNS resolution (metadata.google.internal)"
desc="DNS resolution on the dev probe"
if ssh_cmd "getent hosts metadata.google.internal" >/dev/null; then
  echo "  [PASS] $desc"
  record PASS "$desc"
else
  echo "  [FAIL] $desc"
  record FAIL "$desc"
fi

echo
echo "==> 2. Cloud NAT egress (no external IP on this VM)"
desc="outbound HTTPS via Cloud NAT on the dev probe"
if ssh_cmd "curl -s -o /dev/null -w '%{http_code}' --max-time 5 https://www.google.com | grep -q 200"; then
  echo "  [PASS] $desc"
  record PASS "$desc"
else
  echo "  [FAIL] $desc"
  record FAIL "$desc"
fi

echo
echo "==================== Summary ===================="
for r in "${RESULTS[@]}"; do
  IFS='|' read -r status desc <<< "$r"
  printf "  [%s] %s\n" "$status" "$desc"
done
echo "---------------------------------------------------"
echo "  Passed: $PASS   Failed: $FAIL"
echo "===================================================="

if [[ $FAIL -gt 0 ]]; then
  echo
  echo "Some checks failed. Common causes:"
  echo "  - Cloud NAT / Cloud Router not finished provisioning yet (wait a minute, retry)"
  echo "  - firewall-baseline not applied (check 1-networking was fully applied)"
  echo "  - your gcloud identity lacks roles/iap.tunnelResourceAccessor on this project"
  exit 1
fi

echo "All connectivity checks passed."

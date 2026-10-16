#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://127.0.0.1:8081/}"

if curl --fail --silent --show-error "$URL" >/dev/null; then
    echo "HEALTHY: $URL"
else
    echo "UNHEALTHY: $URL"
    exit 1
fi

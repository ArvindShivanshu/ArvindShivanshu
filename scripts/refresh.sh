#!/usr/bin/env bash
# Trigger immediate real-time stats refresh on GitHub Actions or locally
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

# Get token from git credential helper if not set in environment
TOKEN="${GITHUB_TOKEN:-$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill 2>/dev/null | grep password= | cut -d= -f2)}"

if [ -n "$TOKEN" ]; then
  echo "Triggering cloud GitHub Actions workflow dispatch..."
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Authorization: bearer $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: ArvindShivanshu" \
    "https://api.github.com/repos/ArvindShivanshu/ArvindShivanshu/actions/workflows/stats.yml/dispatches" \
    -d '{"ref":"main"}')
  echo "GitHub Actions dispatch returned HTTP $STATUS"
fi

echo "Running local stats refresh..."
GITHUB_TOKEN="$TOKEN" GH_LOGIN="ArvindShivanshu" python3 scripts/generate_stats.py
echo "Done!"

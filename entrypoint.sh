#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

if (( $# > 0 )); then
    exec supertuxkart-server "$@"
fi

umask 077
server_config="$HOME/.config/supertuxkart/config-0.10/server_config.xml"
server=(supertuxkart-server "--server-config=$server_config")
case "${GAME_MODE:-}" in
    '') ;;
    race) server+=(--mode=0) ;;
    time-trial) server+=(--mode=1) ;;
    soccer) server+=(--mode=3) ;;
    free-for-all) server+=(--mode=2) ;;
    capture-the-flag) server+=(--mode=5) ;;
    *)
        echo "GAME_MODE must be race, time-trial, soccer, free-for-all, capture-the-flag, or empty." >&2
        exit 2
        ;;
esac

case "${PUBLIC_SERVER:-0}" in
    0) ;;
    1) server+=(--public-server) ;;
    *)
        echo "PUBLIC_SERVER must be 0 or 1." >&2
        exit 2
        ;;
esac

if [[ ! -e "$server_config" ]]; then
    cp /usr/local/share/stk/server_config.example.xml "$server_config"
fi

ai_karts=${AI_KARTS:-0}
if [[ "$ai_karts" == 0 ]]; then
    exec "${server[@]}"
fi
if [[ ! "$ai_karts" =~ ^[1-9][0-9]*$ ]]; then
    echo "AI_KARTS must be a non-negative integer." >&2
    exit 2
fi

ai_password=$(xmllint --nonet --xpath 'string(/server-config/private-server-password/@value)' "$server_config")
startup_log_dir=$(mktemp -d)
server_pid=
ai_pid=

cleanup() {
    for pid in "$ai_pid" "$server_pid"; do
        [[ -n "$pid" ]] || continue
        kill -TERM "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
    rm -rf -- "$startup_log_dir"
}

wait_for_server() {
    local status=0
    wait "$server_pid" || status=$?
    server_pid=
    exit "$status"
}

trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

"${server[@]}" --log=2 --stdout=server.log --stdout-dir="$startup_log_dir/" &
server_pid=$!

startup_log="$startup_log_dir/server.log"
for (( attempt = 0; attempt < 60; attempt++ )); do
    if ! kill -0 "$server_pid" 2>/dev/null; then
        wait_for_server
    fi
    if [[ -f "$startup_log" ]] && grep -Fq 'STKHost: Listening has been started.' "$startup_log"; then
        server_port=$(sed -n 's/.*STKHost: Server port is \([0-9][0-9]*\).*/\1/p' "$startup_log" | tail -n 1)
        if [[ -n "$server_port" ]]; then
            supertuxkart-server "--connect-now=127.0.0.1:$server_port" \
                "--server-password=$ai_password" "--network-ai=$ai_karts" &
            ai_pid=$!
            wait_for_server
        fi
    fi
    sleep 1
done

echo "The server did not start listening within 60 seconds." >&2
exit 1

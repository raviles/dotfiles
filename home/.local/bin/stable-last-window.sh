#!/usr/bin/env sh

set -eu

cmd="${1:-}"
session="${2:-}"
current_window="${3:-}"
delay="${4:-2}"

current_key='@stable_last_window_current'
previous_key='@stable_last_window_previous'

promote_window() {
  sleep "$delay"

  active_window="$(tmux display-message -p -t "$session" '#{window_id}' 2>/dev/null || true)"
  [ "$active_window" = "$current_window" ] || exit 0

  stable_current="$(tmux show-options -qv -t "$session" "$current_key" 2>/dev/null || true)"
  [ "$stable_current" = "$current_window" ] && exit 0

  if [ -n "$stable_current" ]; then
    tmux set-option -t "$session" "$previous_key" "$stable_current"
  fi

  tmux set-option -t "$session" "$current_key" "$current_window"
}

toggle_window() {
  stable_current="$(tmux show-options -qv -t "$session" "$current_key" 2>/dev/null || true)"
  stable_previous="$(tmux show-options -qv -t "$session" "$previous_key" 2>/dev/null || true)"

  if [ -z "$stable_current" ] || [ -z "$stable_previous" ]; then
    if [ -n "$stable_current" ] && [ "$current_window" != "$stable_current" ]; then
      tmux select-window -t "$stable_current"
    else
      tmux last-window
    fi
    exit 0
  fi

  if [ "$current_window" = "$stable_current" ]; then
    tmux select-window -t "$stable_previous"
  else
    tmux select-window -t "$stable_current"
  fi
}

seed_sessions() {
  delay_seconds="${2:-2}"

  tmux list-sessions -F '#{session_name} #{window_id}' 2>/dev/null | while IFS=' ' read -r name win_id; do
    [ -n "$name" ] || continue
    [ -n "$win_id" ] || continue
    "$0" promote "$name" "$win_id" "$delay_seconds" &
  done
}

case "$cmd" in
  promote)
    promote_window
    ;;
  toggle)
    toggle_window
    ;;
  seed)
    seed_sessions "$@"
    ;;
  *)
    printf 'Usage: %s {promote|toggle|seed} [args...]\n' "$0" >&2
    exit 2
    ;;
esac

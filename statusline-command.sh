#!/bin/sh
# Claude Code statusLine — mirrors zsh PROMPT='%n@%m : %1~${vcs_info_msg_0_}%# '
input=$(cat)
user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.cwd')
dir=$(basename "$cwd")
branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
    printf '%s@%s : %s (%s)' "$user" "$host" "$dir" "$branch"
else
    printf '%s@%s : %s' "$user" "$host" "$dir"
fi

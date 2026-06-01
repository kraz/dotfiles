#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd=$(echo "$cwd" | sed "s|^$home|~|")

# Get git branch (skip optional locks to avoid blocking)
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks 2>/dev/null | grep -q true; then
  git_branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Build status line with ANSI colors
# Cyan for directory, yellow for git branch, dim for model/context
if [ -n "$git_branch" ]; then
  dir_git=$(printf "\033[36m%s\033[0m \033[33m(%s)\033[0m" "$short_cwd" "$git_branch")
else
  dir_git=$(printf "\033[36m%s\033[0m" "$short_cwd")
fi

if [ -n "$model" ] && [ -n "$remaining" ]; then
  printf "%s  \033[2m%s  ctx: %s%%\033[0m\n" "$dir_git" "$model" "$remaining"
elif [ -n "$model" ]; then
  printf "%s  \033[2m%s\033[0m\n" "$dir_git" "$model"
else
  printf "%s\n" "$dir_git"
fi

if [[ ! -o interactive ]]; then
    return
fi

compctl -K _dockerize dockerize

_dockerize() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(dockerize commands)"
  else
    completions="$(dockerize completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}

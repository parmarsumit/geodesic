#!/usr/bin/env bash
# Allow bash to check the window size to keep prompt with relative to window size
shopt -s checkwinsize

export PROMPT_COMMAND=prompter
function prompter() {
    for hook in ${PROMPT_HOOKS[@]}; do
        "${hook}"
    done
}

PROMPT_HOOKS+=("reload")
function reload() {
  eval $(resize)
}

PROMPT_HOOKS+=("terraform_prompt")
function terraform_prompt() {
  shopt -s nullglob
  TF_FILES=(*.tf)
  if [ ! -z "${TF_FILES}" ]; then
    if [ ! -d ".terraform" ]; then
      echo -e "-> Run 'init-terraform' to use this project"
    fi
  fi
}

# Define our own prompt
PROMPT_HOOKS+=("geodesic_prompt")
function geodesic_prompt() {
       
  case $PROMPT_STYLE in
    plain)
      # 8859-1 codepoints:
      AWS_VAULT_ACTIVE_MARK=$(tput bold)$(tput setab 2)$'»'$(tput sgr0)' '  # green
      AWS_VAULT_INACTIVE_MARK=$'· '
      BLACK_RIGHTWARDS_ARROWHEAD=$'=> '
      BANNER_MARK=$'§ '
      ;;
    *)
      # unicode
      AWS_VAULT_ACTIVE_MARK=$'\u2714 '      # '✔'
      AWS_VAULT_INACTIVE_MARK=$'\u274C '    # '❌'
      BLACK_RIGHTWARDS_ARROWHEAD=$'\u27A4 ' # '➤', suggest '▶' may be present in more fonts
      BANNER_MARK=$'\u29C9 '                # '⧉'
      ;;
  esac

  if [ -n "$AWS_VAULT" ]; then
    STATUS=${AWS_VAULT_ACTIVE_MARK}
  else
    STATUS=${AWS_VAULT_INACTIVE_MARK}
  fi

  if [ -n "${AWS_VAULT}" ]; then
    ROLE_PROMPT="(${AWS_VAULT})"
  else
    ROLE_PROMPT="(none)"
  fi

  PS1=$'${STATUS}'
  PS1+="  ${ROLE_PROMPT} \W "
  PS1+=$'${BLACK_RIGHTWARDS_ARROWHEAD} '

  if [ -n "${BANNER}" ]; then
    PS1=$' ${BANNER_MARK}'" ${BANNER}\n"${PS1}
  fi
  export PS1
}

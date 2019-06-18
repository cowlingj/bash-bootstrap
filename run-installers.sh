#/usr/bin/env bash

set -u -e

declare -a DEFAULT_INSTALLERS=("default-installers.sh")
declare INSTALLERS
declare INSTALL_FILE
usage() {
  cat <<EOF
usage:
  $0 -f <INSTALL_FILE> [[--]<INSTALLERS>...]
  where INSTALL_FILE is the file containing programs to install
  and INSTALLERS are the files used to install programs from INSTALL_FILE.
EOF

  return 0
}

setup() {

  case "$(uname -s)" in
    Darwin) OPTS="getopt" ;;
    Linux)  OPTS="getopts" ;;
    *)
      echo "unsupported OS: $(uname -s)"
      exit 1
    ;;
  esac


  CLEAN_ARGS="$($OPTS 'f:' "$@")"
  eval set -- "$CLEAN_ARGS"

  INSTALLERS=("${DEFAULT_INSTALLERS[@]}")
  local OPTIONS_END="false"
  case "$1" in
    -f)
      INSTALL_FILE="$2"
      shift 2
    ;;
    --)
      OPTIONS_END="true"
      shift
    ;;
    *)
      ! "$OPTIONS_END" && echo "incorrect argument: $1" && usage && exit 1
      INSTALLERS+="$1"
      shift
    ;;
  esac

  [ -z "$INSTALL_FILE" ] &&
    echo "INSTALL_FILE not specified" &&
    usage &&
    exit 1

  for FILE in "$INSTALL_FILE" ${INSTALLERS[@]}; do

    [ ! -f "$FILE" ] &&
      echo "file $FILE doesn't exist" &&
      usage &&
      exit 1
  done

  set -a
    source "${INSTALLERS[@]}"
  set +a

  return 0
}

process_cmd() {
  declare -a EXEC_MODULE
  IFS=' ' read -ra EXEC_MODULE <<< $@
  "${EXEC_MODULE[0]}_install" "${EXEC_MODULE[@]:1}"
}
export -f process_cmd

main() {
  
  setup $@

  local STEP=0
  while true; do

    echo "starting pass: $STEP" 1>&2
   
    local REGEX='^([[:digit:]]+)[[:space:]]+([[:graph:]]+)[[:space:]]+(.*)$'    
    local ACTIVE_FILE="$(mktemp)"
    while read -r LINE; do
 
      [[ "$LINE" =~ $REGEX ]] || continue

      [[ "${BASH_REMATCH[1]}" -eq "$STEP" ]] || continue
      set +e
        rm "$ACTIVE_FILE" 2>/dev/null
      set -e
      echo "${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"      
    done < "$INSTALL_FILE" | xargs -I '{}' bash -c "process_cmd '{}'"

    echo "competed pass: $STEP" 1>&2

    if [ -f "$ACTIVE_FILE" ]; then
      echo "no actions performed in pass $STEP, finishing..." 1>&2
      rm "$ACTIVE_FILE"
      break
    fi
    (( STEP++ ))
  done 
}

main $@

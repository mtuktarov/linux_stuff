#!/bin/bash

usage(){
    cat << EOF
This is a grep wrapper
Usage: $0 [file(s)] [pattern(s)] [grep option(s)]
Examples:
  $0 --help
  $0 -ir /etc/passwd mtuktarov
  $0 error warn /var/log/syslog
EOF
    grep --help | head -n -9 | tail -n +4
}
#if [[ $1 == "--help" ]] ; then
#    usage
#fi
#exit 0
while  [[ $# -gt 0 ]] ; do
    [[ -f $1 || -h $1 ]] && FILES+=($1) && shift && continue
    
    case $1 in
        --help)
            usage
            exit 0
        ;;
        -*|--*)
            ARGS+=($1)
            shift
        ;;
        *)
            TEXT+=("-e $1")
            shift
        ;;
    esac
done

(( ${#FILES[@]} == 0 )) && echo "Files not specified" && exit 1
(( ${#TEXT[@]} == 0 )) && echo "Patterns not specified" && exit 2
grep $(echo "${ARGS[@]} ${TEXT[@]} ${FILES[@]}")
exit 0

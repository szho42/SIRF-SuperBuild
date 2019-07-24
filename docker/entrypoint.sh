#!/bin/bash
show_help(){
echo 'Usage:
  entrypoint.sh [options] [command...]

- Add local user USER_ID:GROUP_ID (fallback 1000:1000)
- Fix permissions in /opt

Flags:
  -h, --help
  -P, --no-fix-permissions
Options:
  -u, --uid
  -g, --gid
  -U, --username
  -k, --skel
Arguments:
  command
'
}

set -o errexit -o pipefail -o noclobber -o nounset
OPTIND=1  # reset getopts

fix_permissions=y
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}
mainUser=${mainUser:-sirfuser}
OLD_HOME=/home-away

OPTIONS=hPu:g:U:k:
LONGOPTS=help,no-fix-permissions,uid:,gid:,username:,skel:

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
[[ ${PIPESTATUS[0]} -ne 0 ]] && exit 2
eval set -- "$PARSED"

while true; do
  case "$1" in
  -h|--help)
    show_help
    exit 0
    ;;
  -P|--no-fix-permissions)
    fix_permissions=n
    shift
    ;;
  -u|--uid)
    USER_ID="$2"
    shift 2
    ;;
  -g|--gid)
    GROUP_ID="$2"
    shift 2
    ;;
  -U|--username)
    mainUser="$2"
    shift 2
    ;;
  -k|--skel)
    OLD_HOME="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
   *)
    echo "Programming error"
    exit 3
    ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# end options

export HOME=/home/$mainUser

if [ -d $HOME ]; then
  cd $HOME
  if [ -n "$@" ]; then
    exec gosu $mainUser "$@"
  else
    exit 0
  fi
fi

cd /
#mv $OLD_HOME $HOME
#cd $HOME

echo "${UID:-}:${GID:-} Creating and switching to: $mainUser:sirf ($USER_ID:$GROUP_ID)"
groupadd --non-unique --system --gid "$GROUP_ID" sirf
#addgroup --quiet --system --gid "$GROUP_ID" sirf
useradd --system --shell /bin/bash -u $USER_ID --non-unique -m --skel $OLD_HOME \
   -N -g sirf -G sudo \
   -p "$(echo virtual | openssl passwd -1 -stdin)" "$mainUser"
#adduser --quiet --system --shell /bin/bash \
#  --no-create-home --home /home/"$mainUser" \
#  --ingroup sirf --uid "$USER_ID" "$mainUser"
echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$mainUser"

if [ "$fix_permissions" = y ]; then
  for i in $(ls -d /opt/*/); do
    echo fixing permissions for $i
    chown -R $mainUser:sirf "$i"
  done
  echo done fixing permissions
fi

cd $HOME
if [ ${#} -ge 1 ]; then
  echo exec $@
  exec gosu $mainUser "$@"
else
  echo done
  exit 0
fi

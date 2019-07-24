#!/bin/bash
# Add local user
# Either use runtime USER_ID:GROUP_ID or fallback 1000:1000

USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}
mainUser=${mainUser:-sirfuser}
OLD_HOME=/home-away
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

echo "$UID:$GID Creating and switching to: $mainUser:sirf ($USER_ID:$GROUP_ID)"
groupadd --non-unique --system --gid "$GROUP_ID" sirf
#addgroup --quiet --system --gid "$GROUP_ID" sirf
useradd --system --shell /bin/bash -u $USER_ID --non-unique -m --skel $OLD_HOME \
   -N -g sirf -G sudo \
   -p "$(echo virtual | openssl passwd -1 -stdin)" "$mainUser"
#adduser --quiet --system --shell /bin/bash \
#  --no-create-home --home /home/"$mainUser" \
#  --ingroup sirf --uid "$USER_ID" "$mainUser"
echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$mainUser"

for i in /opt/* "$HOME"; do
  if [ -d "$i" ]; then
    chown -R $mainUser:sirf "$i"
  fi
done

cd $HOME
if [ -n "$@" ]; then
  exec gosu $mainUser "$@"
else
  exit 0
fi

#!/bin/bash
# Ensure main and secondary users

# ensures $mainUser:sirf,sudo exists
[ -f /usr/local/bin/entrypoint.sh ] && . /usr/local/bin/entrypoint.sh

# ensure secondary users exist
echo -e "user1 v1rtual\nuser2 virtual2" | while read usr pass; do
  [ -d /home/$usr ] \
  || useradd --system --shell /bin/bash --non-unique -m --skel $OLD_HOME \
       -N -g sirf -p "$(echo $pass | openssl passwd -1 -stdin)" $usr
  # -u $USER_ID
done

cd $HOME
exec "$@"

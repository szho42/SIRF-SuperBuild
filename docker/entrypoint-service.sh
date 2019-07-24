#!/bin/bash
# Ensure main and secondary users

#USER_ID=${USER_ID:-1000}
mainUser=${mainUser:-sirfuser}
OLD_HOME=/home-away
export HOME=/home/$mainUser

echo ensure $mainUser:sirf,sudo exists
[ -f /usr/local/bin/entrypoint.sh ] \
  && bash /usr/local/bin/entrypoint.sh -P --skel $OLD_HOME # --uid $USER_ID

echo ensure secondary users exist
echo -e "user1 v1rtual\nuser2 virtual2" | while read usr pass; do
  [ -d /home/$usr ] \
  || useradd --system --shell /bin/bash -m --skel $OLD_HOME \
       -N -g sirf -p "$(echo $pass | openssl passwd -1 -stdin)" $usr
  # -u $USER_ID --non-unique
done

cd $HOME
echo exec "$@"
exec "$@"

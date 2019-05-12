#!/bin/sh

if [ ! -e /etc/pam.d/sshd ]
then
  if [ $DEBUG = true ]
  then
    echo "auth $AUTH /usr/local/lib/security/pam_yubico.so id=$YUBICO_CLIENT_ID key=$YUBICO_SECRET_KEY authfile=/etc/ssh/authorized_yubikeys debug" > /etc/pam.d/sshd
    touch /var/run/pam-debug.log
    chmod go+w /var/run/pam-debug.log
  else
    echo "auth $AUTH /usr/local/lib/security/pam_yubico.so id=$YUBICO_CLIENT_ID key=$YUBICO_SECRET_KEY authfile=/etc/ssh/authorized_yubikeys" > /etc/pam.d/sshd
  fi
fi

ssh-keygen -A && /usr/sbin/sshd -De

#!/bin/sh

if [ ! -e /etc/pam.d/sshd ]
then
  echo "auth $AUTH pam_yubico.so id=$YUBICO_CLIENT_ID key=$YUBICO_SECRET_KEY authfile=/etc/ssh/authorized_yubikeys" > /etc/pam.d/sshd
fi

ssh-keygen -A && /usr/sbin/sshd -De

#!/bin/bash

/bin/ping -q -i 5 www.google.com &
ssh-keygen -A && /usr/sbin/sshd -De

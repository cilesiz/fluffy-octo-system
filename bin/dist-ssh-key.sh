#!/bin/bash
scp rfomerand_ssh2.pub root@$1:.ssh2
ssh root@$1 "echo "Key     rfomerand_ssh2.pub" >> .ssh2/authorization"

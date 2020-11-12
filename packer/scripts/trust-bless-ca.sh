#!/usr/bin/env bash

mv /tmp/cas.pub /etc/ssh/cas.pub
echo "TrustedUserCAKeys /etc/ssh/cas.pub" >> /etc/ssh/sshd_config

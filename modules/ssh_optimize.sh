#!/bin/bash

optimize_ssh() {
    sudo sed -i 's/.*\s*ClientAliveInterval.*/\ClientAliveInterval 30/' /etc/ssh/sshd_config
    sudo sed -i 's/.*\s*ClientAliveCountMax.*/\ClientAliveCountMax 10/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    ss -ntlp
} 

optimize_ssh
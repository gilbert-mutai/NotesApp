#!/bin/bash
MYIP=$(curl -s ifconfig.me)
terraform destroy -var "my_ip=${MYIP}/32" -auto-approve
echo "Resources Destroyed Successfully"

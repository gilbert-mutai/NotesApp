#!/bin/bash
MYIP=$(curl -s ifconfig.me)
terraform apply -var "my_ip=${MYIP}/32" -auto-approve
echo "Applied Terraform with Current IP: ${MYIP}/32"
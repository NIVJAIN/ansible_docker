ip=54.179.98.255
ssh -i vamakp.pem ubuntu@${ip}
# ansible-playbook  -i 54.179.98.255, --private-key ./vamakp.pem nginx.yaml
# curl ${ip}:8080 -Ivk
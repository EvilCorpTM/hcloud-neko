#!/bin/bash
# by github.com/catSIXe
SSHKEYS="--ssh-key PersonalKey --ssh-key AutomationKey"
expire=$(date -d "now 2 hours" +'%s')




UUID=$(cat /proc/sys/kernel/random/uuid)

ipv4=$(hcloud server create --name "$UUID" --label "neko=1" --label "expire=$expire" --image ubuntu-20.04 --type cx41 $SSHKEYS | grep IPv4 | cut -c 7-)
exitCode=255
while [ $exitCode -ne 0 ]; do
	ssh -oStrictHostKeyChecking=no -q root@$ipv4 exit
	exitCode=$?
done

userPW=$(openssl rand -base64 48 | cut -c1-8)
adminPW=$(openssl rand -base64 48 | cut -c1-8)

echo "version: '2.0'
services:
  neko:
    image: nurdism/neko:firefox
    restart: always
    shm_size: '1gb'
    ports:
      - '80:8080'
      - '59000-59100:59000-59100/udp'
    environment:
      DISPLAY: :99.0" > docker-compose.yaml
echo "      NEKO_PASSWORD: '$userPW'" >> docker-compose.yaml
echo "      NEKO_PASSWORD_ADMIN: '$adminPW'" >> docker-compose.yaml
echo "      NEKO_BIND: :8080" >> docker-compose.yaml
echo "      NEKO_EPR: 59000-59100" >> docker-compose.yaml

ssh -oStrictHostKeyChecking=no -q root@$ipv4 "apt update -y; apt upgrade -y; curl -fsSL https://get.docker.com -o get-docker.sh; yes | bash get-docker.sh; apt install docker-compose -y; sudo ufw allow 80/tcp; sudo ufw allow 59000:59100/udp;" >/dev/null
cat docker-compose.yaml | ssh -oStrictHostKeyChecking=no -q root@$ipv4 "cat - > docker-compose.yaml" > /dev/null
ssh -oStrictHostKeyChecking=no -q root@$ipv4 "docker-compose up -d"
rm docker-compose.yaml

echo "http://$ipv4"
echo "User Password: $userPW"
echo "Admin Password: $adminPW"

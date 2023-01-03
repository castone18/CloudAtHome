#!/bin/bash

amiroot=`id -u`
if (( $amiroot !=0 )); then
    echo "You must run this script as root, or with sudo."
    exit 1
fi

mkdir -p ./data/caddy/data
mkdir -p ./data/caddy/config
mkdir -p ./data/ghost/data
[ ! -f "./data/caddy/Caddyfile" ] && cp caddy/Caddyfile ./data/caddy/Caddyfile
[ ! -f ".env" ] && cp dotenv.txt .env
chmod 770 .env
chown root:root .env
docker network ls | grep confined
if [[ $? == 1 ]]; then
    docker network create --internal confined
fi
docker network ls | grep bbw
if [[ $? == 1 ]]; then
    docker network create bbw
fi

source .env

echo "Generic configuration:"
read -p "   Enter your domain name ($MYDOMAIN) : " domain_name
if [ ! -z "$domain_name" ]; then
    MYDOMAIN=$domain_name
    sed -i "s/MYDOMAIN=.*/MYDOMAIN=\"$domain_name\"/" .env
    sed -i "/marker zero/,/marker one/{s%https:.*%https://${MYDOMAIN}, https://www.${MYDOMAIN} \{%}" ./data/caddy/Caddyfile
    sed -i "/marker one/,/marker two/{s%https://cloud.*%https://cloud.${MYDOMAIN}:443 \{%}" ./data/caddy/Caddyfile
    sed -i "/marker two/,/marker three/{s%https://cloud.*%https://cloud.${MYDOMAIN}:8443 \{%}" ./data/caddy/Caddyfile
fi

echo "Caddy configuration:"
read -p "   Enter VPN IP address of household nextcloud server (${MYNEXTCLOUDIP}) : " nextcloud_ip
if [ ! -z "$nextcloud_ip" ]; then
    MYNEXTCLOUDIP=$nextcloud_ip
    sed -i "s/MYNEXTCLOUDIP=.*/MYNEXTCLOUDIP=\"${nextcloud_ip}\"/" .env
    sed -i "/marker one/,/marker two/{s/reverse_proxy.*/reverse_proxy ${MYNEXTCLOUDIP}:11000/}" ./data/caddy/Caddyfile
    sed -i "/marker two/,/marker three/{s%reverse_proxy.*%reverse_proxy https://${MYNEXTCLOUDIP}:8080 \{%}" ./data/caddy/Caddyfile
fi

echo "Ghost blog configuration:"
read -p "   Enter SMTP host name ($MAILHOST) : " smtp_host
if [ ! -z "$smtp_host" ]; then
    MAILHOST=$smtp_host
    sed -i "s/MAILHOST=.*/MAILHOST=\"${smtp_host}\"/" .env
fi
read -p "   Enter SMTP port number ($MAILPORT) : " smtp_port
if [ ! -z "$smtp_port" ]; then
    MAILPORT=$smtp_port
    sed -i "s/MAILPORT=.*/MAILPORT=${smtp_port}/" .env
fi
read -p "   Enter email login user ($MAILUSER) : " email_user
if [ ! -z "$email_user" ]; then
    MAILPORT=$email_user
    sed -i "s/MAILUSER=.*/MAILUSER=\"${email_user}\"/" .env
fi
read -p "   Enter email user password : " -s email_passw
if [ ! -z "$email_passw" ]; then
    MAILPASSW=$email_passw
    sed -i "s/MAILPASSW=.*/MAILPASSW=\"${email_passw}\"/" .env
fi
read -p $'\n'"   Enter email from identity ($MAILFROM) : " email_identity
if [ ! -z "$email_identity" ]; then
    MAILFROM=$email_identity
    sed -i "s/MAILFROM=.*/MAILFROM=\"${email_identity}\"/" .env
fi

cat data/caddy/Caddyfile
read -p "Please verify contents of Caddyfile. Proceed (Y/n) ? " answer
if [ ! -z "$answer" ]; then
    if [[ $answer != "Y" && $answer != "y" ]]; then
        exit 1
    fi
fi

echo ""
echo ""
cat .env
read -p "Please verify contents of docker compose environment variables file. Proceed (Y/n) ? " answer
if [ ! -z "$answer" ]; then
    if [[ $answer != "Y" && $answer != "y" ]]; then
        exit 1
    fi
fi

docker-compose up -d

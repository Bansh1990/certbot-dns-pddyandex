#!/bin/bash

_dir="$(dirname "$0")"

source "$_dir/config.sh"

# Strip only the top domain to get the zone id
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
CREATE_DOMAIN=`echo _acme-challenge.$CERTBOT_DOMAIN | rev | cut -d"." -f 3- | rev`


DOMAIN=`echo $CERTBOT_DOMAIN | rev | cut -d"." -f "1,2" | rev`

# Create TXT record
RECORD_ID=$(curl -s -X POST "https://pddimp.yandex.ru/api2/admin/dns/add" \
     -H "PddToken: $API_KEY" \
     -d "domain=$DOMAIN&type=TXT&content=$CERTBOT_VALIDATION&ttl=600&subdomain=$CREATE_DOMAIN" \
	 | python -c "import sys,json;print(json.load(sys.stdin)['record']['record_id'])")
	
# Save info for cleanup
if [ ! -d /tmp/CERTBOT_$CERTBOT_DOMAIN ];then
        mkdir -m 0700 /tmp/CERTBOT_$CERTBOT_DOMAIN
fi

echo $RECORD_ID > /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID

# Sleep to make sure the change has time to propagate over to DNS
sleep 700



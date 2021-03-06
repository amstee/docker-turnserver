#!/bin/bash

if [ -z $SKIP_AUTO_IP ] && [ -z $EXTERNAL_IP ]
then
    if [ ! -z $USE_IPV4 ]
    then
        EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
        EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
fi

if [ -z $PORT ]
then
    PORT=3478
fi

if [ ! -e /tmp/turnserver.configured ]
then
    if [ -z $SKIP_AUTO_IP ]
    then
        echo external-ip=$EXTERNAL_IP > /etc/turnserver.conf
    fi
    echo listening-port=$PORT >> /etc/turnserver.conf

    if [ ! -z $LISTEN_ON_PUBLIC_IP ]
    then
        echo listening-ip=$EXTERNAL_IP >> /etc/turnserver.conf
    fi

    if [ -z $DISABLE_TLS ]
    then
        echo "#no-tls" >> /etc/turnserver.conf
    else
        echo no-tls >> /etc/turnserver.conf
    fi

    if [ -z $DISABLE_DTLS ]
    then
        echo "#no-dtls" >> /etc/turnserver.conf
    else
        echo no-dtls >> /etc/turnserver.conf
    fi

    if [ -z $REALM_NAME ]
    then
        echo "realm=default.realm.com" >> /etc/tunserver.conf
    else
        echo realm=$REALM_NAME >> /etc/turnserver.conf
    fi

    touch /tmp/turnserver.configured
fi

echo cert=/certificates/turn_server_cert.pem >> /etc/turnserver.conf
echo pkey=/certificates/turn_server_pkey.pem >> /etc/turnserver.conf

exec /usr/bin/turnserver --no-cli --use-auth-secret --static-auth-secret=neo_secret_EH89T7 -r "webrtc.neo.ovh" -a -f >>/var/log/turnserver.log 2>&1

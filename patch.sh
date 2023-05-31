#!/bin/bash
#vars
SKY_DNS="10.73.6.32"



## Close UI Ivanti Client if Open
if pgrep -x "pulseUI" >/dev/null
then
    PULSE_UI_PID=$(pidof pulseUI)
    sudo kill -9 $PULSE_UI_PID
else
    echo "PulseUI not open"
fi
 
sleep 1
 
## Start Ivanti Client (ex pulseUI)
/opt/pulsesecure/bin/pulseUI &

## Ping DNS to check if the VPN Connection is working properly 
while ! ping -c1 $SKY_DNS &>/dev/null
     do echo "SKY DNS $(SKY_DNS) - still unreachable..."
done

sleep 1


## Changing the /etc/resolv.conf configuration
sudo cp -f /etc/resolv.conf .
sed "s/search/search skytech.local/g" resolv.conf > temp-resolv.conf
resolve_search=$(head -n 1 temp-resolv.conf)
sed -i "s/search.*$//g" temp-resolv.conf
sed -i '/^$/d' temp-resolv.conf
sed -i "s/nameserver ${SKY_DNS}//g" temp-resolv.conf
sed -i '/^$/d' temp-resolv.conf

echo "${resolve_search}" >> output-resolv.conf
echo "nameserver ${SKY_DNS}" >> output-resolv.conf
cat temp-resolv.conf >> output-resolv.conf

rm -f temp-resolv.conf 

sudo mv -f output-resolv.conf /etc/resolv.conf
#!/bin/bash
ALL=($(virsh list | grep "i-" | awk '{print $2}'))
for v in `echo ${ALL[@]}`; do
    b=($(grep ${v} /var/log/eucalyptus/* | grep -i teardown ))
    if [ -n "$b" ]; then
        TSDATE=($(date +%H%M%S.%m%d%Y))
        for x in `virsh list | grep "i-" | grep ${v} | awk '{print $1}'`; do
            TSDATE=($(date +%H%M%S.%m%d%Y))
            echo $TSDATE "Detected bad instance, destroying domain: " ${x} " instance id: "${v} | tee -a /tmp/virshclean.log
            virsh destroy ${x}
        done
        for l in `dmsetup table | grep ${v} | cut -f 1 -d ':'`; do
            dmsetup remove  $l; sleep 2; dmsetup remove $l
        done
    else
        TSDATE=($(date +%H%M%S.%m%d%Y))
	echo $TSDATE "domain: " ${x} " instance id: "${v} "is good.  Leaving alone." | tee -a /tmp/virshclean.log
    fi
done

#!/bin/bash
ALL=($(virsh list | grep "i-" | awk '{print $2}'))
for v in `echo ${ALL[@]}`; do
    b=($(grep ${v} /var/log/eucalyptus/* | grep -i teardown ))
    if [ -n "$b" ]; then
        TSDATE=($(date +%H%M%S.%m%d%Y))
        for x in `virsh list | grep "i-" | grep ${v} | awk '{print $1}'`; do
            TSDATE=($(date +%H%M%S.%m%d%Y))
            echo $TSDATE "Detected bad instance, destroying domain: " ${x} " instance id: "${v}
            virst destroy ${x}
            for d in `dmsetup table | grep ${v} | cut -f 1 -d ':'`; do
                dmsetup remove ${d}; sleep 5; dmsetup remove ${d};
            done
            for l in `dmsetup table | grep ${v} | cut -f 1 -d ':' | sed "s/^.*${v}-//"`; do
                WID=($(dmsetup table | grep ${v} | cut -f 1 -d ':'| sed "s/\-/ /g" | awk '{print $2}' | sort -u))
                for LOOP in `losetup -j /var/lib/eucalyptus/instances/work/${WID}/${l}.blocks 2> /dev/null | awk -F":" '{print $1}'`; do
                    losetup -d $LOOP
                done
#                losetup -j ${l}.loopback
            done
        done
    else
        echo "domain: " ${x} " instance id: "${v} "is good.  Leaving alone."
    fi
done
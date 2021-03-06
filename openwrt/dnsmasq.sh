#!/bin/bash
rm -rf dnsmasq.accelerated-domains.conf dnsmasq.bogus-nxdomain.conf dnsmasq.adblock-domains.conf ignore-ips.china.conf gfw-domains.dnsmasq.conf gfw-domains.dnsmasq.ubuntu.conf ignore.list unbound.gfw-domains.conf overture.gfw-domains.conf overture.accelerated-domains.conf unbound.accelerated-domains.conf dnscrypt-blacklist-ips.conf dnscrypt-blacklist-domains.conf unbound.adblock-domains.conf overture.adblock-domains.conf
cnlist() {
    wget -4 -O dnsmasq.accelerated-domains.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
    wget -4 -O dnsmasq.bogus-nxdomain.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/bogus-nxdomain.china.conf
    wget -4 -O dnsmasq.bogus-nxdomain.ext.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/ip.conf
    wget -4 -O apple.china.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf

    # DNS:https://puredns.cn、https://pdomo.me、https://www.onedns.net、https://hixns.cn
    sed -i "s/114.114.114.114/119.29.29.29/g" *.conf

    # dnsmasq.bogus-nxdomain.conf
    cat dnsmasq.bogus-nxdomain.conf dnsmasq.bogus-nxdomain.ext.conf > file.txt
    rm -rf dnsmasq.bogus-nxdomain.ext.conf dnsmasq.bogus-nxdomain.conf
    awk '!x[$0]++' file.txt > dnsmasq.bogus-nxdomain.conf
    rm -rf file.txt
    sort -n dnsmasq.bogus-nxdomain.conf | uniq
    sort -n dnsmasq.bogus-nxdomain.conf | awk '{if($0!=line)print; line=$0}'
    sort -n dnsmasq.bogus-nxdomain.conf | sed '$!N; /^\(.*\)\n\1$/!P; D'

    # dnsmasq.accelerated-domains.conf
    cat dnsmasq.accelerated-domains.conf apple.china.conf > file.txt
    rm -rf apple.china.conf dnsmasq.accelerated-domains.conf
    awk '!x[$0]++' file.txt > dnsmasq.accelerated-domains.conf
    rm -rf file.txt
    cat dnsmasq.accelerated-domains.conf mydns.conf > file.txt
    rm -rf dnsmasq.accelerated-domains.conf
    awk '!x[$0]++' file.txt > dnsmasq.accelerated-domains.conf
    rm -rf file.txt
    sort -n dnsmasq.accelerated-domains.conf | uniq > file.txt
    sort -n file.txt | awk '{if($0!=line)print; line=$0}' > tmp.txt
    sort -n tmp.txt | sed '$!N; /^\(.*\)\n\1$/!P; D' > dnsmasq.accelerated-domains.conf
    rm -rf file.txt tmp.txt
}

cnlist_overture() {
    cat dnsmasq.accelerated-domains.conf | sed 's/server=\///g; s/\/119.29.29.29//g' > overture.accelerated-domains.conf
    sed -i '/107.170.15.247/d' overture.accelerated-domains.conf
}

cnlist_unbound() {
    cat overture.accelerated-domains.conf | sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: 127.0.0.1@8866\n|' > unbound.accelerated-domains.conf
}

cnlist_dnscrypt() {
    cat dnsmasq.accelerated-domains.conf | grep -v '^#server' | sed -e 's|/| |g' -e 's|^server= ||' | sed 's/114.114.114.114/119.29.107.85,118.24.208.197,47.101.136.37,114.115.240.175/g' >dnscrypt-forwarding-rules.conf
    sed -i '/107.170.15.247/d' dnscrypt-forwarding-rules.conf
}

adblock() {
    wget -4 -O - https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt |
    grep ^\|\|[^\*]*\^$ |
    sed -e 's:||:address\=\/:' -e 's:\^:/127\.0\.0\.1:' | uniq > dnsmasq.adblock-domains.conf

    wget -4 -O - https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt |
    grep ^\|\|[^\*]*\^$ |
    sed -e 's:||:address\=\/:' -e 's:\^:/127\.0\.0\.1:' | uniq > adblock.ext.conf

    wget -4 -O - https://easylist-downloads.adblockplus.org/easyprivacy.txt |
    grep ^\|\|[^\*]*\^$ |
    sed -e 's:||:address\=\/:' -e 's:\^:/127\.0\.0\.1:' | uniq >> adblock.ext.conf

    wget -4 -O - https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP-FX.txt |
    grep ^\|\|[^\*]*\^$ |
    sed -e 's:||:address\=\/:' -e 's:\^:/127\.0\.0\.1:' | uniq >> adblock.ext.conf

    wget -4 -O union.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
    sed -i "s/0.0.0.0/127.0.0.1/g" union.conf
    sed -i '/#/d' union.conf
    sed -i '/^$/d' union.conf
    sed -i "s/address\=\/\./address\=\//g" union.conf

    wget -4 -O ad.conf http://iytc.net/tools/ad.conf

    # dnsmasq.adblock-domains.conf
    cat dnsmasq.adblock-domains.conf adblock.ext.conf > file.txt
    rm -rf dnsmasq.adblock-domains.conf adblock.ext.conf
    awk '!x[$0]++' file.txt > dnsmasq.adblock-domains.conf
    rm -rf file.txt
    cat dnsmasq.adblock-domains.conf union.conf > file.txt
    rm -rf dnsmasq.adblock-domains.conf union.conf
    awk '!x[$0]++' file.txt > dnsmasq.adblock-domains.conf
    rm -rf file.txt
    cat dnsmasq.adblock-domains.conf ad.conf > file.txt
    rm -rf dnsmasq.adblock-domains.conf ad.conf
    awk '!x[$0]++' file.txt > dnsmasq.adblock-domains.conf
    rm -rf file.txt
    bash blockad.sh
    cat dnsmasq.adblock-domains.conf blockad.conf > file.txt
    rm -rf dnsmasq.adblock-domains.conf blockad.conf
    awk '!x[$0]++' file.txt > dnsmasq.adblock-domains.conf
    rm -rf file.txt
    cat dnsmasq.adblock-domains.conf myblock.conf > file.txt
    rm -rf dnsmasq.adblock-domains.conf
    awk '!x[$0]++' file.txt > dnsmasq.adblock-domains.conf
    rm -rf file.txt
    sort -n dnsmasq.adblock-domains.conf | uniq > file.txt
    sort -n file.txt | awk '{if($0!=line)print; line=$0}' > tmp.txt
    sort -n tmp.txt | sed '$!N; /^\(.*\)\n\1$/!P; D' > dnsmasq.adblock-domains.conf
    sed -i '/\/m\.baidu\.com\/127/d' dnsmasq.adblock-domains.conf
    sed -i "s/\.\//\//g" dnsmasq.adblock-domains.conf
    rm -rf file.txt tmp.txt
}

adblock_overture() {
    cat dnsmasq.adblock-domains.conf | sed 's/address=\///g; s/\/127\.0\.0\.1//g;' | grep -E -v '([^0-9]|\b)((1[0-9]{2}|2[0-4][0-9]|25[0-5]|[1-9][0-9]|[0-9])\.){3}(1[0-9][0-9]|2[0-4][0-9]|25[0-5]|[1-9][0-9]|[0-9])([^0-9]|\b)' > overture.adblock-domains.conf
}

adblock_unbound() {
    cat overture.adblock-domains.conf | sed -e 's|\(.*\)|local-zone: "\1." redirect|' > unbound.adblock-domains.conf
}

adblock_dnscrypt() {
    cat overture.adblock-domains.conf > toblock-without-shorturl-optimized.lst
    echo 'ad.*' >>dnscrypt-blacklist-domains.conf
    echo 'ad[0-9]*' >>dnscrypt-blacklist-domains.conf
    echo 'ads.*' >>dnscrypt-blacklist-domains.conf
    echo 'ads[0-9]*' >>dnscrypt-blacklist-domains.conf
    cat toblock-without-shorturl-optimized.lst | grep -v '^#' | tr -s '\n' | tr A-Z a-z | grep -v '^ad\.' | grep -v -e '^ad[0-9]' | grep -v '^ads\.' | grep -v -e '^ads[0-9]' | rev | sort -n | uniq | rev >>dnscrypt-blacklist-domains.conf
    rm toblock-without-shorturl-optimized.lst
}

chinalist_ips() {
    # china_ipv4_ipv6_list：https://raw.githubusercontent.com/LisonFan/china_ip_list/master/china_ipv4_ipv6_list
    wget -4 -O ignore-ips.china.conf https://raw.githubusercontent.com/LisonFan/china_ip_list/master/china_ipv4_list
}

blacklist_ips_dnscrypt() {
    cat dnsmasq.bogus-nxdomain.conf | grep -v '^#bogus' | grep bogus-nxdomain | sed 's/bogus-nxdomain=//g' > dnscrypt-blacklist-ips.conf
    cat dnsmasq.adblock-domains.conf | sed 's/address=\///g; s/\/127\.0\.0\.1//g;' | grep -E '([^0-9]|\b)((1[0-9]{2}|2[0-4][0-9]|25[0-5]|[1-9][0-9]|[0-9])\.){3}(1[0-9][0-9]|2[0-4][0-9]|25[0-5]|[1-9][0-9]|[0-9])([^0-9]|\b)' >> dnscrypt-blacklist-ips.conf
    sort -n dnscrypt-blacklist-ips.conf | uniq > file.txt
    sort -n file.txt | awk '{if($0!=line)print; line=$0}'> tmp.txt
    sort -n tmp.txt | sed '$!N; /^\(.*\)\n\1$/!P; D'> dnscrypt-blacklist-ips.conf
    rm file.txt tmp.txt
}

gfwlist() {
    # wget -4 -O gfw-domains.dnsmasq.conf https://cokebar.github.io/gfwlist2dnsmasq/dnsmasq_gfwlist_ipset.conf
    # wget -4 -O gfw-domains.dnsmasq.conf https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/gh-pages/dnsmasq_gfwlist_ipset.conf
    wget -4 -O gfwlist2dnsmasq.sh https://raw.githubusercontent.com/cokebar/gfwlist2dnsmasq/master/gfwlist2dnsmasq.sh && chmod +x gfwlist2dnsmasq.sh && bash gfwlist2dnsmasq.sh -s gfwlist -o gfw-domains.dnsmasq.conf && bash gfwlist2dnsmasq.sh -d 8.8.8.8 -p 53 -s gfwlist -o gfw-domains.dnsmasq.ubuntu.conf
    rm -rf gfwlist2dnsmasq.sh
}

gfwlist_overture() {
    cat gfw-domains.dnsmasq.conf | sed 's/ipset=\///g; s/\/gfwlist//g; /^server/d; /#/d' > overture.gfw-domains.conf
}

gfwlist_unbound() {
    cat overture.gfw-domains.conf | sed -e 's|\(.*\)|forward-zone:\n  name: "\1."\n  forward-addr: 127.0.0.1@8865\n|' > unbound.gfw-domains.conf
}

gfwlist_dnscrypt() {
    wget -4 -O dnscrypt-cloaking-rules.conf https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnscrypt-proxy-cloaking.txt
}

pushcommit() {
    git add -A
    git commit -m "Update *.conf"
    git push origin master
}

cnlist
cnlist_overture
cnlist_unbound
cnlist_dnscrypt
adblock
adblock_overture
adblock_unbound
adblock_dnscrypt
chinalist_ips
blacklist_ips_dnscrypt
gfwlist
gfwlist_overture
gfwlist_unbound
gfwlist_dnscrypt
#pushcommit

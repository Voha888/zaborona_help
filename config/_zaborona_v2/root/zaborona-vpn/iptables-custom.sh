#!/bin/bash

WAN_4="ens3"
WAN_6="ens3"
VPN_ADDR_4=""
VPN_ADDR_6=""

### DROP TORRENTS ###
iptables -I FORWARD 1 -m string --string "BitTorrent" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "BitTorrent protocol" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "peer_id=" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string ".torrent" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "announce.php?passkey=" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "torrent" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "announce" --algo bm --to 65535 -j DROP
iptables -I FORWARD 1 -m string --string "info_hash" --algo bm --to 65535 -j DROP
### DROP TORRENTS ###

iptables -t mangle -A PREROUTING -m string --algo bm --string "BitTorrent" -j DROP
iptables -t mangle -A PREROUTING -m string --string "get_peers" --algo bm -j DROP
iptables -t mangle -A PREROUTING -m string --string "announce_peer" --algo bm -j DROP
iptables -t mangle -A PREROUTING -m string --string "find_node" --algo bm -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "BitTorrent" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "peer_id=" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string ".torrent" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "torrent" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "announce" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "info_hash" -j DROP
iptables -t mangle -A PREROUTING -p udp -m string --algo bm --string "tracker" -j DROP

iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "BitTorrent" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "peer_id=" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string ".torrent" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "torrent" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "announce" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "info_hash" -j DROP
iptables -t mangle -A POSTROUTING -p udp -m string --algo bm --string "tracker" -j DROP

#
# DNS Redirect to localhost
#iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT
#iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT

#

iptables -t mangle -I POSTROUTING -p tcp --dport 22 -j DROP

iptables -t mangle -I POSTROUTING -p tcp --dport 25 -j DROP
iptables -t mangle -I POSTROUTING -p tcp --dport 465 -j DROP
iptables -t mangle -I POSTROUTING -p tcp --dport 587 -j DROP

iptables -t mangle -I POSTROUTING -p tcp --dport 1337 -j DROP
iptables -t mangle -I POSTROUTING -p tcp --dport 6969 -j DROP

#
iptables -A FORWARD -i $WAN_4 -o zaborona+ -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -o $WAN_4 -s 192.168.0.0/16 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

### DROP NETWORKS ###
### 224.0.0.0/4 (MULTICAST D)
### 240.0.0.0/5 (E)
iptables -I INPUT -i $WAN_4 -s 224.0.0.0/4 -j DROP
iptables -I INPUT -i $WAN_4 -s 240.0.0.0/5 -j DROP
### DROP NETWORKS ###

# PREROUTING - Access For VPN-users (PPTP). All traffic
#iptables -t nat -I POSTROUTING -p tcp -s 192.168.115.0/24 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE
#iptables -I FORWARD -p gre -j ACCEPT
#iptables -I FORWARD -i $WAN_4 -p tcp --dport 1723 -j ACCEPT
#iptables -I FORWARD -i $WAN_4 -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#iptables -I FORWARD -i ppp+ -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT

############################
#iptables -I FORWARD -i $WAN_4 -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD -i ppp+ -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
# PPTP
#iptables -t nat -I POSTROUTING -p tcp -s 192.168.216.0/22 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE
# L2TP-IPsec
#iptables -t nat -I POSTROUTING -p tcp -s 192.168.212.0/22 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE
# IKEv2-IPsec
iptables -I INPUT -i $WAN_4 -p esp -j ACCEPT
#iptables -t nat -I POSTROUTING -p tcp -s 192.168.208.0/22 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE
# WireGuard
#iptables -t nat -I POSTROUTING -p tcp -s 192.168.220.0/22 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE
#iptables -t nat -I POSTROUTING -p udp -s 192.168.220.0/22 -d 0.0.0.0/0 -o $WAN_4 -j MASQUERADE

#iptables -I FORWARD -i $WAN_4 -p tcp --dport 1723 -j ACCEPT
iptables -I FORWARD -p gre -j ACCEPT
iptables -I INPUT -p gre -j ACCEPT

iptables -I INPUT -i $WAN_4 -p udp --dport 500 -j ACCEPT
iptables -I INPUT -i $WAN_4 -p tcp --dport 500 -j ACCEPT
iptables -I INPUT -i $WAN_4 -p udp --dport 4500 -j ACCEPT
iptables -I INPUT -i $WAN_4 -p udp --dport 1701 -j ACCEPT
iptables -I INPUT -i $WAN_4 -p tcp --dport 1723 -j ACCEPT

#iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -I FORWARD -s 192.168.115.0/24  -j ACCEPT
#iptables -I FORWARD -s 192.168.116.0/24  -j ACCEPT
#iptables -I FORWARD -s 192.168.120.0/21  -j ACCEPT
#iptables -I FORWARD -s 192.168.80.0/24  -j ACCEPT
############################

### INDIVIDUAL CFG ###
# Examlpe: iptables -I FORWARD -s 192.168.216.5/32 -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
#iptables -I FORWARD -s 192.168.216.2/32 -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
#iptables -I FORWARD -s 192.168.17.0/24 -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
#iptables -I FORWARD -s 192.168.16.0/24 -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
#iptables -I FORWARD -s 192.168.15.0/24 -o $WAN_4 -d 0.0.0.0/0 -j ACCEPT
### INDIVIDUAL CFG ###

# OUTPUT Tor
iptables -t nat -I PREROUTING -p udp --dport 53 -m string --hex-string "|056f6e696f6e00|" --algo bm -j REDIRECT --to-ports 5300
iptables -t nat -I OUTPUT -p udp --dport 53 -m string --hex-string "|056f6e696f6e00|" --algo bm -j REDIRECT --to-ports 5300
#iptables -t nat -I PREROUTING -p tcp -d 192.168.13.0/24 -j REDIRECT --to-port 9040
#iptables -t nat -I OUTPUT -p tcp -d 192.168.13.0/24 -j REDIRECT --to-port 9040
 
exit 0

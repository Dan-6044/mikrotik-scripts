# --- System Identity ---
/system identity set name="Dev-Router"

# --- IP Addressing ---
/ip address add address=192.168.88.1/24 interface=ether1 comment="LAN"
/ip pool add name=dev-pool ranges=192.168.88.10-192.168.88.100
/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=8.8.8.8
/ip dhcp-server add name=dev-dhcp interface=ether1 address-pool=dev-pool lease-time=1h disabled=no

# --- DNS ---
/ip dns set servers=8.8.8.8 allow-remote-requests=yes

# --- Routes & NAT ---
/ip route add dst-address=0.0.0.0/0 gateway=192.168.1.1
/ip firewall nat add chain=srcnat out-interface=ether2 action=masquerade comment="NAT"

# --- Basic Firewall Rules ---
/ip firewall filter add chain=input action=accept protocol=tcp dst-port=8291 comment="Allow Winbox"
/ip firewall filter add chain=input action=accept protocol=icmp comment="Allow Ping"
/ip firewall filter add chain=input action=drop in-interface=ether2 comment="Drop WAN access to router"

# --- Bandwidth Limits (Simple Queues) ---
/queue simple add name="Limit-192.168.88.50" target=192.168.88.50/32 max-limit=2M/1M comment="Limit test device"
/queue simple add name="Limit-Network" target=192.168.88.0/24 max-limit=10M/5M comment="Limit entire dev network"

# --- Mock VPN (L2TP Server Setup) ---
/interface l2tp-server server set enabled=yes default-profile=default use-ipsec=no
/ppp secret add name="devvpn" password="vpn123" service=l2tp profile=default local-address=192.168.88.1 remote-address=192.168.88.200 comment="Dev VPN User"

# --- Optional: Wireless ---
/interface wireless set wlan1 ssid="DevNetwork" mode=ap-bridge frequency=2412 disabled=no
/ip dhcp-server add name=wlan-dhcp interface=wlan1 address-pool=dev-pool lease-time=1h disabled=no

# --- Dev User ---
/user add name=dev password=dev123 group=full comment="Dev Admin Account"

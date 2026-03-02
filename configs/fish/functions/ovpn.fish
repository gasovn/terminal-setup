function ovpn
    sudo /usr/bin/openvpn --config ~/.openvpn/vpn.ovpn --auth-user-pass ~/.openvpn/auth.txt
end

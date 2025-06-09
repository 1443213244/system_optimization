#!/bin/bash

optimize_network() {
    iface=$(ip route get 223.5.5.5 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}') && \
    sudo -u root bash -c "
    for opt in \
        tx-checksumming \
        tx-checksum-ip-generic \
        scatter-gather \
        tx-scatter-gather \
        generic-segmentation-offload \
        generic-receive-offload \
        tcp-segmentation-offload \
        tx-tcp-segmentation \
        tx-tcp-ecn-segmentation \
        tx-tcp6-segmentation \
        udp-fragmentation-offload \
        tx-nocache-copy \
        rx-gro-hw \
        rx-gro-list \
        rx-udp-gro-forwarding; do
        ethtool -K $iface \$opt on
    done
    ethtool -k $iface | grep -v fixed
    "
    iface=$(ip route get 223.5.5.5 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    sudo tc qdisc replace dev "$iface" root pfifo_fast
    return 0
} 

optimize_network
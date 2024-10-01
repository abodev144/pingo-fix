#!/bin/bash

# Function to check if the network interface is up
check_interface() {
    echo "Checking network interfaces..."
    IFACE=$(ip addr | grep "10.1.0.4" | awk '{print $NF}')
    if [ -z "$IFACE" ]; then
        echo "ERROR: The network interface with IP 10.1.0.4 is not configured. Please check your network settings."
        exit 1
    else
        echo "Network interface $IFACE with IP 10.1.0.4 is up."
    fi
}

# Function to check if we can ping the local machine (loopback)
check_local_ping() {
    echo "Checking if the machine can ping itself..."
    if ping -c 3 127.0.0.1 > /dev/null; then
        echo "Local ping successful."
    else
        echo "ERROR: The machine cannot ping itself."
        exit 1
    fi
}

# Function to check firewall status (ufw)
check_firewall() {
    echo "Checking if firewall is enabled..."
    if command -v ufw >/dev/null 2>&1; then
        UFW_STATUS=$(sudo ufw status | grep -i "active")
        if [ -n "$UFW_STATUS" ]; then
            echo "Firewall is active. Disabling firewall temporarily..."
            sudo ufw disable
        else
            echo "Firewall is not active."
        fi
    else
        echo "ufw is not installed. Skipping firewall check."
    fi
}

# Function to check iptables rules
flush_iptables() {
    echo "Flushing iptables rules to allow ICMP (ping)..."
    sudo iptables -F
    sudo ip6tables -F
    echo "iptables rules flushed."
}

# Function to check the routing table
check_routes() {
    echo "Checking routing table..."
    route -n
    echo "If the destination route for 10.1.0.4 is not listed, please add it manually."
}

# Function to ping the target machine
ping_target() {
    echo "Pinging worker1.linsoft.tn (10.1.0.4)..."
    if ping -c 3 10.1.0.4 > /dev/null; then
        echo "Ping to worker1.linsoft.tn successful!"
    else
        echo "ERROR: Cannot ping worker1.linsoft.tn. Please check your network configuration."
        exit 1
    fi
}

# Main script execution
echo "Starting network diagnostics..."

check_interface
check_local_ping
check_firewall
flush_iptables
check_routes
ping_target

echo "Diagnostics completed. If the issue persists, please check network configurations manually."

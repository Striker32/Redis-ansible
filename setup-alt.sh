#!/bin/bash
set -e

echo "[+] Настройка сети в ALT Linux..."


# 1. Настройка IP-адреса
IFACE_DIR="/etc/net/ifaces/enp0s3"
mkdir -p "$IFACE_DIR"

echo "BOOTPROTO=static
TYPE=eth
NM_CONTROLLED=no
DISABLED=no" > "$IFACE_DIR/options"

echo "192.168.1.101/24" > "$IFACE_DIR/ipv4address"

echo "[+] Перезапуск сети..."
systemctl restart network


# 2. Настройка SSH
echo "[+] Обновление списка пакетов и установка SSH-сервера..."
apt-get update && apt-get dist-upgrade -y
apt-get install -y openssh-server

SSHD_CONFIG="/etc/openssh/sshd_config"
echo "[+] Настройка sshd_config..."

sed -i 's/^#\?Port .*/Port 22/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords yes/' "$SSHD_CONFIG"

echo "[+] Перезапуск sshd..."
systemctl restart sshd


# 5. Включение IP forwarding
echo "[+] Включение IP forwarding в /etc/sysctl.conf..."
SYSCTL_CONF="/etc/sysctl.conf"
NET_SYSCTL="/etc/net/sysctl.conf"

grep -q '^net.ipv4.ip_forward' "$SYSCTL_CONF" && \
    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' "$SYSCTL_CONF" || \
    echo 'net.ipv4.ip_forward=1' >> "$SYSCTL_CONF"

echo "[+] Коррекция /etc/net/sysctl.conf..."
sed -i 's/^net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' "$NET_SYSCTL"

echo "[+] Применение настроек sysctl..."
sysctl -p


echo "[+] Установка git и ansible..."
apt-get update && apt-get install -y git ansible

echo "[+] Настройка iptables NAT (MASQUERADE)..."
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o enp0s8 -j MASQUERADE

echo "[+] Сохранение iptables в /root/rules..."
iptables-save > /root/rules

echo "[+] Добавление восстановления правил в crontab..."
(crontab -l 2>/dev/null; echo "@reboot /sbin/iptables-restore < /root/rules") | crontab -

echo "[✓] Настройка ALT Linux завершена."


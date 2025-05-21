#!/bin/bash
set -e

echo "[+] Настройка сети для Astra Linux..."


# 1. Настройка сети
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.1.102
    netmask 255.255.255.0
    gateway 192.168.1.101
    dns-nameservers 8.8.8.8
EOF

echo "[+] Отключение NetworkManager (если установлен)..."
if systemctl is-active --quiet NetworkManager; then
    systemctl stop NetworkManager
    systemctl disable NetworkManager
fi

echo "[+] Создание /etc/resolv.conf..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "[+] Перезапуск networking..."
systemctl restart networking


# 2. Настройка SSH
echo "[+] Настройка sshd_config..."
SSHD_CONFIG="/etc/ssh/sshd_config"

# Изменить или добавить необходимые параметры
sed -i 's/^#\?Port .*/Port 22/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords yes/' "$SSHD_CONFIG"

echo "[+] Перезапуск sshd..."
systemctl restart ssh

echo "[✓] Настройка Astra Linux завершена."

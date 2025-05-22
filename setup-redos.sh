#!/bin/bash
set -e

echo "[+] Настройка сети для Red OS..."

NM_CONF_PATH="/etc/NetworkManager/system-connections/enp0s3.nmconnection"

# 1. Создание/замена сетевой конфигурации
cat > "$NM_CONF_PATH" <<EOF
[connection]
id=enp0s3
uuid=5956e1f8-a8a9-3f6a-b2a4-40200733055e
type=ethernet
autoconnect-priority=-999
interface-name=enp0s3
timestamp=$(date +%s)

[ethernet]

[ipv4]
address1=192.168.1.103/24,192.168.1.101
method=manual
dns=8.8.8.8

[ipv6]
addr-gen-mode=eui64
method=auto

[proxy]
EOF

echo "[+] Назначение прав на конфигурационный файл..."
chmod 600 "$NM_CONF_PATH"

echo "[+] Перезапуск NetworkManager..."
systemctl restart NetworkManager

echo "[+] Создание /etc/resolv.conf..."
echo "192.168.1.102 astra.redis" >> /etc/hosts


# 2. Настройка SSH
echo "[+] Настройка sshd_config..."
SSHD_CONFIG="/etc/ssh/sshd_config"

sed -i 's/^#\?Port .*/Port 22/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords yes/' "$SSHD_CONFIG"

echo "[+] Перезапуск sshd..."
systemctl restart sshd

echo "[✓] Настройка Red OS завершена успешно."

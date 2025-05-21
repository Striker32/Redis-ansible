# 3. Генерация SSH ключей
echo "[+] Генерация SSH-ключа..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh


ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# 4. Копирование ключа на удалённые машины
echo "[+] Копирование ключей на другие хосты..."
for ip in 192.168.1.101 192.168.1.102 192.168.1.103; do
    echo "[>] Копируем ключ на $ip"
    ssh-copy-id -o StrictHostKeyChecking=no "root@$ip"
done

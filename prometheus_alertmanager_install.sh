#!/bin/bash

# Обновляем список доступных пакетов
sudo apt update

# Устанавливаем необходимые пакеты
sudo apt install -y wget

# Скачиваем последнюю версию Alertmanager
ALERTMANAGER_VERSION="0.27.0" # Проверьте актуальную версию на официальном сайте Alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz

# Распаковываем скачанный архив
tar -xvzf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz

# Переходим в директорию Alertmanager
cd alertmanager-${ALERTMANAGER_VERSION}.linux-amd64

# Создаем директорию для конфигурационных файлов Alertmanager
mkdir -p /etc/alertmanager

# Копируем конфигурационный файл по умолчанию
cp -r ./alertmanager.yml /etc/alertmanager/

# Создаем systemd unit файл для Alertmanager
cat <<EOF | sudo tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager Server
Documentation=https://prometheus.io/docs/alerting/alertmanager/
After=network-online.target

[Service]
User=$(whoami)
Restart=on-failure

ExecStart=$(pwd)/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

[Install]
WantedBy=multi-user.target
EOF

# Запускаем Alertmanager и добавляем его в автозагрузку
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager

echo "Alertmanager успешно установлен и запущен. Можно открыть интерфейс Alertmanager в браузере, перейдя по адресу http://your_server_ip:9093"

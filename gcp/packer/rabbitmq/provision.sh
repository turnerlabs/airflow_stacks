#!/usr/bin/bash -x

set -e

sudo apt-get -y update
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list

wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -

wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_20.2.2-1~debian~jessie_amd64.deb
echo "------------------- pulling down erlang -------------------"

sudo apt-get -y install libwxbase3.0-0v5
sudo apt-get -y install libwxgtk3.0-0v5
sudo apt-get -y install libsctp1
echo "------------------- install erlang dependencies -------------------"

sudo dpkg -i esl-erlang_20.2.2-1~debian~jessie_amd64.deb
echo "------------------- install erlang -------------------"

rm esl-erlang_20.2.2-1~debian~jessie_amd64.deb
echo "------------------- remove erlang file -------------------"

sudo cp /home/ubuntu/erlang /etc/apt/preferences.d/erlang

sudo mkdir /etc/systemd/system/rabbitmq-server.service.d

sudo cp /home/ubuntu/limits.conf /etc/systemd/system/rabbitmq-server.service.d/limits.conf

sudo apt-cache policy
echo "------------------- apply policy -------------------"

sudo apt-get update
echo "------------------- apt update part 2complete -------------------"

sudo apt-get -y install -f
echo "------------------- apt install fix complete -------------------"

sudo apt-get -y install rabbitmq-server
echo "------------------- apt install of rabbitmq complete -------------------"

sudo rabbitmq-plugins enable rabbitmq_management
echo "------------------- enable rabbitmq mgmt complete -------------------"

sudo systemctl daemon-reload

sudo service rabbitmq-server stop

sudo service rabbitmq-server start
echo "------------------- stopping and starting of rabbitmq complete -------------------"

sudo systemctl enable rabbitmq-server
echo "------------------- enable autostart of rabbitmq complete -------------------"

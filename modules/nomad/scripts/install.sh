#!/usr/bin/env bash
set -e

echo "Installing Nomad..."

sudo mkdir -p /opt/nomad/data
sudo mkdir -p /etc/nomad.d
sudo mv /tmp/server.hcl /etc/nomad.d

chmod +x /usr/local/bin/nomad

# Read from the file we created

# Write the flags to a temporary file
cat >/tmp/nomad_flags << EOF
NOMAD_FLAGS="-server -data-dir /opt/nomad/data -config /etc/nomad.d"
EOF


if [ -f /tmp/upstart.conf ];
then
  echo "Installing Upstart service..."
  sudo mkdir -p /etc/nomad.d
  sudo mkdir -p /etc/service
  sudo chown root:root /tmp/upstart.conf
  sudo mv /tmp/upstart.conf /etc/init/nomad.conf
  sudo chmod 0644 /etc/init/nomad.conf
  sudo mv /tmp/nomad_flags /etc/service/nomad
  sudo chmod 0644 /etc/service/nomad
else
  echo "Installing Systemd service..."
  sudo mkdir -p /etc/systemd/system/nomad.d
  sudo chown root:root /tmp/nomad.service
  sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service
  sudo chmod 0644 /etc/systemd/system/nomad.service
  sudo mkdir -p /etc/sysconfig/
  sudo mv /tmp/nomad_flags /etc/sysconfig/nomad
  sudo chown root:root /etc/sysconfig/nomad
  sudo chmod 0644 /etc/sysconfig/nomad
fi

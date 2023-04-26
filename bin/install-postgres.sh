#!/usr/bin/env bash

# Installs and configures PostgreSQL

sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

sudo systemctl enable postgresql
sudo systemctl start postgresql

psql() {
    sudo -i -u postgres psql -c "${1}"
}

save() {
    sudo tee "$2" <<< "$1" > /dev/null
}

conf() {
    sudo sed -i "s/#$1/g" /etc/postgresql/*/main/postgresql.conf
}

# Generate random password
password="$(openssl rand -base64 30)"

# Create a .pgpass file to store the credentials
pgpass="/root/.pgpass"
save "localhost:*:*:postgres:${password}" "${pgpass}"
sudo chmod 600 "${pgpass}"

# Set the password for the 'postgres' user
psql "ALTER USER postgres WITH PASSWORD '${password}';"

# Configure Postgres for production use
conf "listen_addresses = 'localhost'/listen_addresses = '*'"
conf "log_destination = 'stderr'/log_destination = 'csvlog'"
conf "logging_collector = off/logging_collector = on"
conf "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'/log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'"
conf "log_truncate_on_rotation = off/log_truncate_on_rotation = on"
conf "log_rotation_age = 1d/log_rotation_age = 1d"
conf "log_rotation_size = 10MB/log_rotation_size = 10MB"

# Allow connections from any IP address
sudo tee -a /etc/postgresql/*/main/pg_hba.conf <<< \
    "host all all 0.0.0.0/0 md5" > /dev/null

# Restart the Postgres service to apply the changes
sudo systemctl restart postgresql

# Set up a new Postgres database
database="db_$(openssl rand -hex 4)"
username="user_$(openssl rand -hex 4)"
password="$(openssl rand -base64 30)"
psql "CREATE USER ${username} WITH PASSWORD '${password}';"
psql "CREATE DATABASE ${database} OWNER ${username};"
psql "GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${username};"

sudo mkdir -p /root/secrets
save "$database" /root/secrets/postgres_db
save "$username" /root/secrets/postgres_user
save "$password" /root/secrets/postgres_password

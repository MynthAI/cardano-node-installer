#!/usr/bin/env bash

# Installs and configures PostgreSQL

sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

sudo systemctl enable postgresql
sudo systemctl start postgresql

# Generate random password
POSTGRES_PASSWORD="$(openssl rand -base64 30)"

# Create a .pgpass file to store the credentials
PGPASS_FILE="/root/.pgpass"
echo "localhost:*:*:postgres:${POSTGRES_PASSWORD}" | \
    sudo tee "${PGPASS_FILE}" > /dev/null
chmod 600 "${PGPASS_FILE}"

# Set the password for the 'postgres' user
sudo -i -u postgres psql \
    -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';"

# Configure Postgres for production use
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#log_destination = 'stderr'/log_destination = 'csvlog'/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#logging_collector = off/logging_collector = on/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'/log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#log_truncate_on_rotation = off/log_truncate_on_rotation = on/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#log_rotation_age = 1d/log_rotation_age = 1d/g" /etc/postgresql/*/main/postgresql.conf
sudo sed -i "s/#log_rotation_size = 10MB/log_rotation_size = 10MB/g" /etc/postgresql/*/main/postgresql.conf

# Allow connections from any IP address
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf > /dev/null

# Restart the Postgres service to apply the changes
sudo systemctl restart postgresql

# Set up a new Postgres database
database="db_$(openssl rand -hex 4)"
username="user_$(openssl rand -hex 4)"
password="$(openssl rand -base64 30)"
sudo -i -u postgres psql \
    -c "CREATE USER ${username} WITH PASSWORD '${password}';"
sudo -i -u postgres psql \
    -c "CREATE DATABASE ${database} OWNER ${username};"
sudo -i -u postgres psql \
    -c "GRANT ALL PRIVILEGES ON DATABASE ${database}
        TO ${username};"

sudo mkdir -p /root/secrets
echo -n "$database" | sudo tee /root/secrets/postgres_db \
    > /dev/null
echo -n "$username" | sudo tee /root/secrets/postgres_user \
    > /dev/null
echo -n "$password" | sudo tee /root/secrets/postgres_password \
    > /dev/null

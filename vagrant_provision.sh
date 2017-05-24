#!/bin/sh

# © Lau Taanrskov
# Licensed under Apache License 2.0
# From https://github.com/lau/vagrant_elixir
# Modified for Code::Stats

ERLANG_VERSION=19.3
ELIXIR_VERSION=1.4.4
NODE_VERSION=7

# Note: password is for postgres user "postgres"
POSTGRES_DB_PASS=postgres
POSTGRES_VERSION=9.6

# Set language and locale
apt-get install -y language-pack-en
locale-gen --purge en_US.UTF-8
echo "LC_ALL='en_US.UTF-8'" >> /etc/environment
dpkg-reconfigure locales

# Install basic packages
# inotify is installed because it's a Phoenix dependency
apt-get -qq update
apt-get install -y \
wget \
git \
unzip \
build-essential \
ntp \
inotify-tools

# Install Erlang
echo "deb http://packages.erlang-solutions.com/ubuntu zesty contrib" >> /etc/apt/sources.list && \
apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
apt-get -qq update && \
apt-get install -y -f \
esl-erlang="1:${ERLANG_VERSION}"

# Install Elixir
cd / && mkdir -p elixir && cd elixir && \
wget -q https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip && \
unzip Precompiled.zip && \
rm -f Precompiled.zip && \
ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
ln -s /elixir/bin/mix /usr/local/bin/mix && \
ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar for the ubuntu user
su - ubuntu -c '/usr/local/bin/mix local.hex --force && /usr/local/bin/mix local.rebar --force'

# Postgres
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
apt-get update
apt-get -y install postgresql-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION

PG_CONF="/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"
echo "client_encoding = utf8" >> "$PG_CONF" # Set client encoding to UTF8
service postgresql restart

cat << EOF | su - postgres -c psql
ALTER USER postgres WITH ENCRYPTED PASSWORD '$POSTGRES_DB_PASS';
EOF

# Install nodejs and npm
curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
apt-get install -y \
nodejs

# Install imagemagick
apt-get install -y imagemagick

# If seeds.exs exists we assume it is a Phoenix project
if [ -f /vagrant/priv/repo/seeds.exs ]
  then
    # Set up and migrate database
    su - ubuntu -c 'cd /vagrant && mix deps.get && mix ecto.create && mix ecto.migrate'
    # Run Phoenix seed data script
    su - ubuntu -c 'cd /vagrant && mix run priv/repo/seeds.exs'
fi

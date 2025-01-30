#!/bin/sh

SCTIPR_DIR=$(cd $(dirname $0);pwd)
cd ${SCTIPR_DIR}

mkdir -p volumes/fossology
mkdir -p volumes/postgresql/data

sudo chown -R 1000:1000 ./volumes
sudo chown -R 999:999 ./volumes/postgresql
sudo chmod -R 755 ./volumes

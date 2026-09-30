hello:
    @echo "Hello world"
init:
    git init

status:
    git status

add:
    git add .

commit message:
    git commit -m "{{message}}"

log:
    git log --oneline

sync remote_url:
    git remote add origin {{remote_url}}
    git branch -M main
    git push -u origin main

clean:
    -rm tmp.txt


DB_NAME := "ma_base"
DB_USER := "postgres"

# Création de la base de données
db-create:
    sudo -u {{DB_USER}} createdb {{DB_NAME}}

# Insertion de tables/entités
db-insert:
    sudo -u {{DB_USER}} psql -d {{DB_NAME}} -c "CREATE TABLE IF NOT EXISTS test (id serial PRIMARY KEY);"
    sudo -u {{DB_USER}} psql -d {{DB_NAME}} -c "INSERT INTO test DEFAULT VALUES;"

# Migration de la base
db-migrate:
    @echo "Simulation de migration en cours..."
    sudo -u {{DB_USER}} psql -d {{DB_NAME}} -f migrations.sql

# Downgrade vers une base vide
db-downgrade:
    sudo -u {{DB_USER}} dropdb {{DB_NAME}}
    sudo -u {{DB_USER}} createdb {{DB_NAME}}
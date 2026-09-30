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

# Définition de la variable de connexion PostgreSQL
export DATABASE_URL := "postgres://app_user:app_password@localhost:5432/app_db?sslmode=disable"

# Affiche la liste des commandes disponibles
default:
    @just --list

# Démarrage du conteneur PostgreSQL
up-db:
    docker compose up -d

# Arret du conteneur PostgreSQL
down-db:
    docker compose down

# Génération d'une nouvelle migration (usage : just new add_users_table)
new name:
    dbmate new {{ name }}

# Upgrade vers la dernière migration (toutes les migrations en attente)
migrate:
    dbmate up

# Downgrade vers une base de données totalement vierge (annule tout)
reset:
    dbmate rollback --all

# Upgrade de la migration suivante par rapport à celle en cours (+1)
step-up:
    dbmate up --limit 1

# Downgrade de la migration précédente par rapport à celle en cours (-1)
step-down:
    dbmate rollback

# Dump du SQL généré entre deux migrations données (usage : just dump 20260101000000 20260102000000)
dump from_version to_version:
    @echo "-- Différences SQL de {{ from_version }} vers {{ to_version }} --"
    @for f in $(ls db/migrations/*.sql | sort); do \
        version=$(basename "$f" | cut -d'_' -f1); \
        if [ "$version" -gt "{{ from_version }}" ] && [ "$version" -le "{{ to_version }}" ]; then \
            echo "-- Migration : $$f --"; \
            sed -n '/^-- migrate:up/,/^-- migrate:down/p' "$$f" | grep -v '^-- migrate:'; \
            echo ""; \
        fi; \
    done
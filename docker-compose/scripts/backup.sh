#!/bin/bash

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/postgres_backup_$DATE.sql"

echo "🗄️ Criando backup do banco de dados..."

# Criar diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Fazer backup
docker-compose exec postgres pg_dump -U postgres postgres > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Backup criado: $BACKUP_FILE"
    
    # Manter apenas os 5 backups mais recentes
    ls -t $BACKUP_DIR/postgres_backup_*.sql | tail -n +6 | xargs -r rm
    echo "🧹 Backups antigos removidos (mantendo 5 mais recentes)"
else
    echo "❌ Erro ao criar backup"
    exit 1
fi
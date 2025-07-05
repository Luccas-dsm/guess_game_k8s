#!/bin/bash

SERVICE=${1:-"all"}

echo "🔄 Atualizando serviços: $SERVICE"

case $SERVICE in
    "backend")
        echo "🔧 Atualizando apenas backend..."
        docker-compose build backend
        docker-compose up -d --no-deps backend
        ;;
    "frontend")
        echo "🌐 Atualizando apenas frontend..."
        docker-compose build frontend
        docker-compose up -d --no-deps frontend
        ;;
    "proxy")
        echo "🔀 Atualizando apenas proxy..."
        docker-compose build proxy
        docker-compose up -d --no-deps proxy
        ;;
    "all")
        echo "🔄 Atualizando todos os serviços..."
        
        # Fazer backup antes da atualização
        echo "📦 Fazendo backup..."
        ./scripts/backup.sh
        
        # Rebuild das imagens
        echo "🔨 Rebuilding imagens..."
        docker-compose build
        
        # Rolling update (um serviço por vez)
        echo "🔄 Rolling update do backend..."
        docker-compose up -d --no-deps backend
        sleep 5
        
        echo "🔄 Rolling update do frontend..."
        docker-compose up -d --no-deps frontend
        sleep 5
        
        echo "🔄 Rolling update do proxy..."
        docker-compose up -d --no-deps proxy
        ;;
    *)
        echo "❌ Serviço desconhecido: $SERVICE"
        echo "💡 Uso: $0 [backend|frontend|proxy|all]"
        exit 1
        ;;
esac

echo "⏳ Aguardando serviços..."
sleep 10

echo "📊 Status após atualização:"
docker-compose ps

echo "✅ Atualização concluída!"
echo "🌐 Teste: http://localhost:3001"
#!/bin/bash

echo "🚀 Iniciando Guess Game..."

# Para containers existentes
docker-compose down

# Build e start
docker-compose up --build -d

echo "⏳ Aguardando 30 segundos..."
sleep 30

echo "📊 Status:"
docker-compose ps

echo "🌐 Acesse: http://localhost:3001"
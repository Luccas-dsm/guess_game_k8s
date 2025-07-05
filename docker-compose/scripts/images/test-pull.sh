#!/bin/bash

# Configurações
DOCKER_USERNAME=${1:-"seuusuario"}
VERSION=${2:-"latest"}
PROJECT_NAME="guess-game"

echo "🧪 Testando pull das imagens do Docker Hub..."

# Remover imagens locais para testar pull
echo "🗑️ Removendo imagens locais..."
docker rmi $DOCKER_USERNAME/$PROJECT_NAME-backend:$VERSION 2>/dev/null || true
docker rmi $DOCKER_USERNAME/$PROJECT_NAME-frontend:$VERSION 2>/dev/null || true
docker rmi $DOCKER_USERNAME/$PROJECT_NAME-proxy:$VERSION 2>/dev/null || true

# Testar pull
echo "📥 Testando pull backend..."
docker pull $DOCKER_USERNAME/$PROJECT_NAME-backend:$VERSION

echo "📥 Testando pull frontend..."
docker pull $DOCKER_USERNAME/$PROJECT_NAME-frontend:$VERSION

echo "📥 Testando pull proxy..."
docker pull $DOCKER_USERNAME/$PROJECT_NAME-proxy:$VERSION

echo "✅ Pull test concluído!"
echo "📋 Imagens disponíveis:"
docker images | grep $DOCKER_USERNAME/$PROJECT_NAME
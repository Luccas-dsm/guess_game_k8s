#!/bin/bash

# Configurações
DOCKER_USERNAME=${1:-"luccasdsm"}  # Substitua pelo seu usuário do Docker Hub
VERSION=${2:-"latest"}
PROJECT_NAME="guess-game"

echo "🔨 Building imagens para Docker Hub..."
echo "📦 Usuário: $DOCKER_USERNAME"
echo "🏷️  Versão: $VERSION"

# Build das imagens com tags para Docker Hub
echo "🔧 Building backend..."
docker build -t $DOCKER_USERNAME/$PROJECT_NAME-backend:$VERSION \
             -t $DOCKER_USERNAME/$PROJECT_NAME-backend:latest \
             ../backend/

echo "🌐 Building frontend..."
docker build -t $DOCKER_USERNAME/$PROJECT_NAME-frontend:$VERSION \
             -t $DOCKER_USERNAME/$PROJECT_NAME-frontend:latest \
             --build-arg REACT_APP_BACKEND_URL=http://localhost:3001/api \
             ../frontend/

echo "🔀 Building proxy..."
docker build -t $DOCKER_USERNAME/$PROJECT_NAME-proxy:$VERSION \
             -t $DOCKER_USERNAME/$PROJECT_NAME-proxy:latest \
             ../nginx/

echo "📋 Listando imagens criadas:"
docker images | grep $DOCKER_USERNAME/$PROJECT_NAME

echo "✅ Build concluído!"
echo "💡 Para fazer push: ./push-images.sh $DOCKER_USERNAME $VERSION"
#!/bin/bash

# Configurações
DOCKER_USERNAME=${1:-"seuusuario"}
VERSION=${2:-"latest"}
PROJECT_NAME="guess-game"

echo "🚀 Fazendo push das imagens para Docker Hub..."
echo "📦 Usuário: $DOCKER_USERNAME"
echo "🏷️  Versão: $VERSION"

# Verificar se está logado no Docker Hub
if ! docker info | grep -q "Username"; then
    echo "🔑 Fazendo login no Docker Hub..."
    docker login
fi

# Push das imagens
echo "📤 Push backend..."
docker push $DOCKER_USERNAME/$PROJECT_NAME-backend:$VERSION
docker push $DOCKER_USERNAME/$PROJECT_NAME-backend:latest

echo "📤 Push frontend..."
docker push $DOCKER_USERNAME/$PROJECT_NAME-frontend:$VERSION
docker push $DOCKER_USERNAME/$PROJECT_NAME-frontend:latest

echo "📤 Push proxy..."
docker push $DOCKER_USERNAME/$PROJECT_NAME-proxy:$VERSION
docker push $DOCKER_USERNAME/$PROJECT_NAME-proxy:latest

# Salvar informações das imagens
echo "📝 Salvando informações das imagens..."
cat > image-tags.txt << EOF
# Guess Game Images - $VERSION
# Gerado em: $(date)

Backend: $DOCKER_USERNAME/$PROJECT_NAME-backend:$VERSION
Frontend: $DOCKER_USERNAME/$PROJECT_NAME-frontend:$VERSION
Proxy: $DOCKER_USERNAME/$PROJECT_NAME-proxy:$VERSION

# URLs Docker Hub:
# https://hub.docker.com/r/$DOCKER_USERNAME/$PROJECT_NAME-backend
# https://hub.docker.com/r/$DOCKER_USERNAME/$PROJECT_NAME-frontend
# https://hub.docker.com/r/$DOCKER_USERNAME/$PROJECT_NAME-proxy
EOF

echo "✅ Push concluído!"
echo "📋 Informações salvas em: image-tags.txt"
echo "🌐 Verifique no Docker Hub: https://hub.docker.com/u/$DOCKER_USERNAME"
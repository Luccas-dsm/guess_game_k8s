#!/bin/bash

REPLICAS=${1:-3}

echo "🔧 Escalando backend para $REPLICAS instâncias..."

docker-compose up -d --scale backend=$REPLICAS

echo "📊 Status após escalar:"
docker-compose ps

echo "✅ Backend escalado para $REPLICAS instâncias!"
echo "🧪 Teste o load balancing acessando: http://localhost:3001"
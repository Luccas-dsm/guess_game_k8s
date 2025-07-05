#!/bin/bash

echo "🩺 Verificando saúde dos serviços..."

# Função para testar URL
test_url() {
    local url=$1
    local name=$2
    
    if curl -f -s "$url" > /dev/null; then
        echo "✅ $name está OK"
        return 0
    else
        echo "❌ $name com problema"
        return 1
    fi
}

# Testes
echo "🔍 Testando conectividade..."

# Proxy (entrada principal)
test_url "http://localhost:3001" "Proxy/Frontend"

# Backend via proxy
test_url "http://localhost:3001/health" "Backend via Proxy"

# PostgreSQL (conexão direta)
if docker-compose exec postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL está OK"
else
    echo "❌ PostgreSQL com problema"
fi

echo ""
echo "📊 Status dos containers:"
docker-compose ps

echo ""
echo "💾 Uso de volumes:"
docker volume ls | grep docker-compose

echo ""
echo "🔗 URLs de acesso:"
echo "   🌐 Principal: http://localhost:3001"
echo "   🗄️ PostgreSQL: localhost:5433 (postgres/secretpass)"
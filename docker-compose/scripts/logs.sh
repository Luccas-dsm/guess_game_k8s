#!/bin/bash

echo "📋 Logs do Guess Game"
echo "Pressione Ctrl+C para sair"
echo "------------------------"

if [ "$1" = "" ]; then
    echo "💡 Uso: $0 [serviço]"
    echo "Serviços disponíveis: postgres, backend, frontend, proxy"
    echo "Sem parâmetro = todos os logs"
    echo ""
    
    # Mostra logs de todos os serviços
    docker-compose logs -f --tail=50
else
    # Mostra logs de um serviço específico
    docker-compose logs -f --tail=100 $1
fi
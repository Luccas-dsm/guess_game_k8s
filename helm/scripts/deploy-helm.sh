#!/bin/bash

echo "🚀 Deploy Guess Game via Helm..."

# Verificar se Helm está instalado
if ! command -v helm &> /dev/null; then
    echo "❌ Helm não encontrado!"
    exit 1
fi

# Lint do chart
echo "🔍 Validando chart..."
helm lint guess-game/

# Deploy ou upgrade
if helm list | grep -q guess-game-helm; then
    echo "♻️ Fazendo upgrade..."
    helm upgrade guess-game-helm ./guess-game
else
    echo "🆕 Fazendo install..."
    helm install guess-game-helm ./guess-game
fi

# Aguardar pods
echo "⏳ Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=postgres -n guess-game --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n guess-game --timeout=120s

echo "📊 Status final:"
kubectl get all -n guess-game

echo "🎉 Deploy via Helm concluído!"
echo "📋 Helm releases:"
helm list
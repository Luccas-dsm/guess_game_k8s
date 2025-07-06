#!/bin/bash

echo "🧪 Testando HPA do Backend..."

# Verificar status atual do HPA
echo "📊 Status atual do HPA:"
kubectl get hpa -n guess-game

echo ""
echo "📊 Pods atuais:"
kubectl get pods -n guess-game -l app=backend

echo ""
echo "🔥 Gerando carga no backend..."
echo "💡 Executando 100 requests simultâneos por 2 minutos..."

# Gerar carga usando múltiplos curls em background
for i in {1..10}; do
    {
        for j in {1..100}; do
            curl -s http://localhost:30300/api/create \
                -H "Content-Type: application/json" \
                -d '{"password":"load-test-'$i'-'$j'"}' > /dev/null 2>&1
            sleep 0.1
        done
    } &
done

echo "⏳ Aguardando 30 segundos para métricas aparecerem..."
sleep 30

echo "📊 Status HPA após carga:"
kubectl get hpa -n guess-game

echo ""
echo "📊 Pods após carga:"
kubectl get pods -n guess-game -l app=backend

echo ""
echo "🔍 Monitorando HPA por 2 minutos (Ctrl+C para parar):"
kubectl get hpa -n guess-game -w
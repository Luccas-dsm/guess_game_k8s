#!/bin/bash

echo "🚀 Deploying Guess Game no Kubernetes..."

# Verificar se kubectl está configurado
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ kubectl não conectado ao cluster"
    echo "💡 Configure: kubectl config current-context"
    exit 1
fi

echo "📋 Cluster atual:"
kubectl config current-context

# Aplicar manifests na ordem correta
echo "1️⃣ Criando namespace..."
kubectl apply -f namespace.yaml

echo "2️⃣ Criando ConfigMap e Secrets..."
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml

echo "3️⃣ Criando Persistent Volumes..."
kubectl apply -f postgres/postgres-pv.yaml
kubectl apply -f postgres/postgres-pvc.yaml

echo "4️⃣ Deploying PostgreSQL..."
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml

echo "⏳ Aguardando PostgreSQL ficar pronto..."
kubectl wait --for=condition=ready pod -l app=postgres -n guess-game --timeout=120s

echo "5️⃣ Deploying Backend..."
kubectl apply -f backend/backend-deployment.yaml
kubectl apply -f backend/backend-service.yaml

echo "⏳ Aguardando Backend ficar pronto..."
kubectl wait --for=condition=ready pod -l app=backend -n guess-game --timeout=120s

echo "6️⃣ Deploying Frontend..."
kubectl apply -f frontend/frontend-deployment.yaml
kubectl apply -f frontend/frontend-service.yaml

echo "7️⃣ Deploying Proxy..."
kubectl apply -f proxy/proxy-deployment.yaml
kubectl apply -f proxy/proxy-service.yaml

echo "⏳ Aguardando todos os pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=frontend -n guess-game --timeout=120s
kubectl wait --for=condition=ready pod -l app=proxy -n guess-game --timeout=120s

echo "📊 Status final:"
kubectl get all -n guess-game

echo "✅ Deploy completo!"
echo "🌐 Acesse: http://localhost:30300"
echo "🔍 Logs: kubectl logs -l app=backend -n guess-game"
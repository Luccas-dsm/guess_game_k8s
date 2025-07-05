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

echo "📊 Status do PostgreSQL:"
kubectl get pods -n guess-game -l app=postgres

echo "✅ Deploy inicial completo!"
echo "🔍 Verificar: kubectl get all -n guess-game"
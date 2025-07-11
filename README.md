# 🎮 Guess Game - Docker & Kubernetes

Um jogo de adivinhação completo implementado com **Flask + React + PostgreSQL**, orquestrado com **Docker Compose** e **Kubernetes**, e gerenciado via **Helm Charts**.

## 🚀 Quick Start

### Docker Compose (Desenvolvimento) (precisa de manutenção)

```bash
cd docker-compose
./scripts/start.sh
# Acesse: http://localhost:3001
```

### Kubernetes (Produção) (funcional)

```bash
cd kubernetes
./scripts/deploy.sh
# Acesse: http://localhost:30300
```

### Helm Charts (Enterprise) (precisa de manutenção)

```bash
cd helm
helm install guess-game-helm ./guess-game
# Acesse: http://localhost:30300
```

## 📋 Pré-requisitos

- **Docker Desktop** (com Kubernetes habilitado)
- **Git Bash** (Windows) ou terminal Unix-like
- **Helm 3.x** (para deploy via Helm)
- **Portas livres**: 3001, 5433, 30300

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Browser     │────│   Load Balancer │────│    Frontend     │
│                 │    │     (NGINX)     │    │     (React)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌─────────────────┐    ┌─────────────────┐
                       │     Backend     │────│   PostgreSQL    │
                       │ (Flask x3 pods) │    │  (Persistent)   │
                       └─────────────────┘    └─────────────────┘
```

## 📂 Estrutura do Projeto

```
guess-game-docker-k8s/
├── docker-compose/          # Docker Compose para desenvolvimento
│   ├── docker-compose.yml   # Orquestração principal
│   ├── .env                 # Variáveis de ambiente
│   └── scripts/             # Scripts de automação
├── kubernetes/              # Manifests Kubernetes para produção
│   ├── backend/             # Deployments e Services do backend
│   ├── frontend/            # Deployments e Services do frontend
│   ├── postgres/            # Deployments e Services do PostgreSQL
│   └── scripts/             # Scripts de deploy
├── helm/                    # Helm Charts para gestão enterprise
│   └── guess-game/          # Chart principal
├── images/                  # Scripts para Docker Hub
└── docs/                    # Documentação adicional
```

## 🔧 Ambientes de Deploy

### 1. **Desenvolvimento Local** (Docker Compose)

- **Use quando**: Desenvolvimento, testes locais, debugging
- **Características**: Hot reload, logs detalhados, fácil debugging
- **Comando**: `cd docker-compose && ./scripts/start.sh`
- **URL**: http://localhost:3001

### 2. **Produção Simples** (Kubernetes)

- **Use quando**: Deploy direto no cluster, controle total dos manifests
- **Características**: Load balancing, auto-healing, scaling manual
- **Comando**: `cd kubernetes && ./scripts/deploy.sh`
- **URL**: http://localhost:30300

### 3. **Produção Enterprise** (Helm)

- **Use quando**: Gestão de releases, multiple environments, rollbacks
- **Características**: Versionamento, templates, valores customizáveis
- **Comando**: `cd helm && helm install guess-game-helm ./guess-game`
- **URL**: http://localhost:30300

## ⚡ Comandos Essenciais

### Docker Compose

```bash
# Iniciar ambiente completo
./docker-compose/scripts/start.sh

# Escalar backend para 5 instâncias
./docker-compose/scripts/scale.sh 5

# Ver logs em tempo real
./docker-compose/scripts/logs.sh

# Fazer backup do banco
./docker-compose/scripts/backup.sh

# Parar tudo
./docker-compose/scripts/stop.sh
```

### Kubernetes

```bash
# Navegar para pasta Kubernetes
cd Kubernetes
# Deploy completo
./scripts/deploy.sh

# Verificar status
kubectl get all -n guess-game

# Escalar backend manualmente
kubectl scale deployment backend-deployment --replicas=5 -n guess-game

# Port-forward para debug
kubectl port-forward svc/backend-service 8080:5000 -n guess-game

# Limpar tudo
kubectl delete namespace guess-game
```

### Helm

```bash
# Install/Deploy
helm install guess-game-helm ./helm/guess-game

# Upgrade/Atualização
helm upgrade guess-game-helm ./helm/guess-game

# Ver releases
helm list

# Rollback
helm rollback guess-game-helm 1

# Uninstall
helm uninstall guess-game-helm
```

## 🎮 Como Jogar

1. **Acesse a aplicação** (URLs acima conforme ambiente)
2. **Criar Jogo**: Clique em "Create a Game", digite uma palavra secreta
3. **Salve o Game ID** que aparece na tela
4. **Adivinhar**: Clique em "Join a Game", digite o Game ID e suas tentativas
5. **Feedback**: O sistema mostra quantas letras estão corretas e posições

## 🔍 Monitoramento e Debug

### Logs

```bash
# Docker Compose
docker-compose logs -f [serviço]

# Kubernetes
kubectl logs -l app=backend -n guess-game -f

# Helm (mesmo comando do Kubernetes)
kubectl logs -l app=backend -n guess-game -f
```

### Health Checks

```bash
# Backend
curl http://localhost:3001/api/health

# Teste criação de jogo
curl -X POST http://localhost:3001/api/create \
  -H "Content-Type: application/json" \
  -d '{"password":"teste"}'
```

### Métricas

```bash
# Ver uso de recursos
docker stats                           # Docker Compose
kubectl top pods -n guess-game         # Kubernetes

# Ver HPA (Horizontal Pod Autoscaler)
kubectl get hpa -n guess-game
```

## 🚢 Deploy em Produção

### 1. Prepare as imagens

```bash
cd images
./build-images.sh seuuruario v1.0.0
./push-images.sh seuusuario v1.0.0
```

### 2. Configure o ambiente

```bash
# Kubernetes
kubectl create namespace guess-game-prod
kubectl apply -f kubernetes/ -n guess-game-prod

# Helm
helm install guess-game-prod ./helm/guess-game \
  --set global.namespace=guess-game-prod \
  --set global.imageRegistry=docker.io/seuusuario
```

## 📊 Recursos Implementados

### ✅ **Docker Compose**

- Multi-container orchestration
- Volume persistence
- Load balancing (NGINX)
- Health checks
- Auto-restart policies
- Development optimized

### ✅ **Kubernetes**

- Pod orchestration
- Service discovery
- Persistent volumes
- ConfigMaps & Secrets
- Horizontal Pod Autoscaler (HPA)
- Liveness & Readiness probes
- Production optimized

### ✅ **Helm Charts**

- Template engine
- Values customization
- Release management
- Rollback capabilities
- Multiple environments
- Enterprise ready

### ✅ **Observabilidade**

- Health endpoints
- Structured logging
- Resource monitoring
- Error handling
- Performance metrics

## 🔒 Segurança

- Secrets management (Kubernetes Secrets)
- Non-root containers
- Resource limits
- Network policies ready
- RBAC compatible

## 📈 Escalabilidade

- **Horizontal**: Kubernetes HPA + múltiplas réplicas
- **Vertical**: Resource requests/limits configuráveis
- **Load Balancing**: NGINX upstream com failover
- **Persistência**: PostgreSQL com volumes persistentes

## 🛠️ Troubleshooting

### Problemas Comuns

**Porta ocupada:**

```bash
# Verificar portas em uso
netstat -an | findstr :3001
# Alterar porta no .env ou values.yaml
```

**Imagens não encontradas:**

```bash
# Verificar se estão no Docker Hub
docker pull seuusuario/guess-game-backend:latest
# Ou rebuild local
./images/build-images.sh seuusuario latest
```

**Pods crashando:**

```bash
# Ver logs detalhados
kubectl describe pod <pod-name> -n guess-game
kubectl logs <pod-name> -n guess-game
```

**Banco não conecta:**

```bash
# Verificar se PostgreSQL está healthy
kubectl get pods -l app=postgres -n guess-game
kubectl logs -l app=postgres -n guess-game
```

## 🔗 Links Úteis

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [React Documentation](https://reactjs.org/docs/)

---

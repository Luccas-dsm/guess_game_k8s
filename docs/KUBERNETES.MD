# 🚢 Kubernetes Guide - Guess Game

## 📋 Componentes Instalados

### Core Components

- **Namespace**: `guess-game` - Isolamento de recursos
- **ConfigMap**: `guess-game-config` - Configurações da aplicação
- **Secret**: `guess-game-secrets` - Senhas e dados sensíveis

### Storage

- **PersistentVolume**: `postgres-pv` - Volume para PostgreSQL
- **PersistentVolumeClaim**: `postgres-pvc` - Claim do volume

### Database

- **Deployment**: `postgres-deployment` - PostgreSQL (1 réplica)
- **Service**: `postgres-service` - ClusterIP para acesso interno

### Backend

- **Deployment**: `backend-deployment` - Flask API (3 réplicas)
- **Service**: `backend-service` - ClusterIP para acesso interno
- **HorizontalPodAutoscaler**: `backend-hpa` - Auto-scaling baseado em CPU/Memory

### Frontend

- **Deployment**: `frontend-deployment` - React SPA (2 réplicas)
- **Service**: `frontend-service` - ClusterIP para acesso interno

### Load Balancer

- **Deployment**: `proxy-deployment` - NGINX proxy (1 réplica)
- **Service**: `proxy-service` - NodePort 30300 para acesso externo

## 🚀 Deploy Commands

### Deploy Completo

```bash
cd kubernetes
./scripts/deploy.sh
```

### Deploy Manual (Ordem específica)

```bash
# 1. Namespace e configurações
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml

# 2. Storage
kubectl apply -f postgres/postgres-pv.yaml
kubectl apply -f postgres/postgres-pvc.yaml

# 3. Database
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml

# 4. Backend
kubectl apply -f backend/backend-deployment.yaml
kubectl apply -f backend/backend-service.yaml
kubectl apply -f backend/backend-hpa.yaml

# 5. Frontend
kubectl apply -f frontend/frontend-deployment.yaml
kubectl apply -f frontend/frontend-service.yaml

# 6. Proxy
kubectl apply -f proxy/proxy-deployment.yaml
kubectl apply -f proxy/proxy-service.yaml
```

## 📊 Monitoramento

### Status Geral

```bash
# Ver todos os recursos
kubectl get all -n guess-game

# Ver eventos
kubectl get events -n guess-game --sort-by='.lastTimestamp'

# Ver recursos com watch
kubectl get pods -n guess-game -w
```

### Logs

```bash
# Logs do backend
kubectl logs -l app=backend -n guess-game -f

# Logs de um pod específico
kubectl logs postgres-deployment-xxx -n guess-game

# Logs anteriores (se pod reiniciou)
kubectl logs backend-deployment-xxx -n guess-game --previous
```

### Debugging

```bash
# Descrever pod com problemas
kubectl describe pod <pod-name> -n guess-game

# Entrar em um pod
kubectl exec -it <pod-name> -n guess-game -- /bin/bash

# Port-forward para teste local
kubectl port-forward svc/backend-service 8080:5000 -n guess-game
```

## ⚡ Scaling

### Manual Scaling

```bash
# Escalar backend
kubectl scale deployment backend-deployment --replicas=5 -n guess-game

# Escalar frontend
kubectl scale deployment frontend-deployment --replicas=3 -n guess-game

# Ver status do scaling
kubectl get deployments -n guess-game
```

### Auto Scaling (HPA)

```bash
# Ver status do HPA
kubectl get hpa -n guess-game

# Descrição detalhada
kubectl describe hpa backend-hpa -n guess-game

# Testar carga (simular CPU usage)
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -n guess-game -- /bin/sh
# Dentro do pod:
while true; do wget -q -O- http://backend-service:5000/health; done
```

## 🔄 Updates e Rollbacks

### Rolling Updates

```bash
# Atualizar imagem do backend
kubectl set image deployment/backend-deployment backend=luccasdsm/guess-game-backend:v2.0.0 -n guess-game

# Ver status do rollout
kubectl rollout status deployment/backend-deployment -n guess-game

# Ver histórico
kubectl rollout history deployment/backend-deployment -n guess-game
```

### Rollbacks

```bash
# Rollback para versão anterior
kubectl rollout undo deployment/backend-deployment -n guess-game

# Rollback para versão específica
kubectl rollout undo deployment/backend-deployment --to-revision=2 -n guess-game
```

## 💾 Backup e Restore

### Backup do PostgreSQL

```bash
# Criar backup
kubectl exec postgres-deployment-xxx -n guess-game -- pg_dump -U postgres postgres > backup.sql

# Backup via job
kubectl create job postgres-backup --image=postgres:15-alpine -n guess-game -- \
  sh -c "pg_dump -h postgres-service -U postgres postgres > /tmp/backup.sql"
```

### Restore

```bash
# Restaurar backup
kubectl exec -i postgres-deployment-xxx -n guess-game -- psql -U postgres -d postgres < backup.sql
```

## 🔒 Segurança

### Secrets Management

```bash
# Ver secrets
kubectl get secrets -n guess-game

# Criar novo secret
kubectl create secret generic new-secret --from-literal=key=value -n guess-game

# Editar secret existente
kubectl edit secret guess-game-secrets -n guess-game
```

### RBAC (Role-Based Access Control)

```bash
# Criar service account
kubectl create serviceaccount guess-game-sa -n guess-game

# Criar role
kubectl create role guess-game-role --verb=get,list,watch --resource=pods -n guess-game

# Bind role
kubectl create rolebinding guess-game-binding --role=guess-game-role --serviceaccount=guess-game:guess-game-sa -n guess-game
```

## 🌐 Networking

### Services

```bash
# Ver services
kubectl get svc -n guess-game

# Testar conectividade interna
kubectl run test-pod --image=busybox --rm -it -n guess-game -- \
  wget -qO- http://backend-service:5000/health
```

### Ingress (Opcional)

```bash
# Aplicar ingress
kubectl apply -f ingress/ingress.yaml

# Ver ingress
kubectl get ingress -n guess-game

# Adicionar ao /etc/hosts (Windows: C:\Windows\System32\drivers\etc\hosts)
echo "127.0.0.1 guess-game.local" >> /etc/hosts
```

## 📈 Performance

### Resource Monitoring

```bash
# Ver uso de recursos
kubectl top pods -n guess-game
kubectl top nodes

# Ver resource requests/limits
kubectl describe pod <pod-name> -n guess-game | grep -A 5 "Requests\|Limits"
```

### Performance Tuning

```yaml
# Ajustar resources no deployment
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 🗑️ Cleanup

### Cleanup Completo

```bash
# Deletar namespace (remove tudo)
kubectl delete namespace guess-game

# Ou deletar seletivamente
kubectl delete all --all -n guess-game
kubectl delete pvc --all -n guess-game
kubectl delete configmap --all -n guess-game
kubectl delete secret --all -n guess-game
```

### Cleanup Específico

```bash
# Deletar apenas deployments
kubectl delete deployment --all -n guess-game

# Manter dados, deletar apenas aplicação
kubectl delete deployment,service -l app!=postgres -n guess-game
```

## 🚨 Troubleshooting

### Problemas Comuns

**Pod stuck em Pending:**

```bash
kubectl describe pod <pod-name> -n guess-game
# Verificar: resources insuficientes, PVC não bound, node selector
```

**ImagePullBackOff:**

```bash
kubectl describe pod <pod-name> -n guess-game
# Verificar: nome da imagem, tag, registry access
```

**CrashLoopBackOff:**

```bash
kubectl logs <pod-name> -n guess-game
kubectl logs <pod-name> -n guess-game --previous
# Verificar: código da aplicação, healthchecks, dependências
```

**Service não acessível:**

```bash
kubectl get endpoints -n guess-game
# Verificar: labels dos pods, selector do service, portas
```

### Debug Tools

```bash
# Pod de debug temporário
kubectl run debug --image=busybox --rm -it --restart=Never -n guess-game -- sh

# Netshoot para debug de rede
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -n guess-game -- bash
```

## 📚 Recursos Úteis

- [Kubernetes Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Troubleshooting Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/)
- [Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

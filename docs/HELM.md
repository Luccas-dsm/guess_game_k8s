# ⚓ Helm Guide - Guess Game

## 📦 Chart Structure

```
helm/guess-game/
├── Chart.yaml              # Metadados do chart
├── values.yaml             # Valores padrão
├── values-dev.yaml         # Valores para desenvolvimento
├── values-prod.yaml        # Valores para produção
└── templates/
    ├── _helpers.tpl         # Templates auxiliares
    ├── namespace.yaml       # Namespace
    ├── postgres/
    │   ├── postgres-deployment.yaml
    │   └── postgres-service.yaml
    ├── backend/
    │   ├── backend-deployment.yaml
    │   └── backend-service.yaml
    └── frontend/
        ├── frontend-deployment.yaml
        └── frontend-service.yaml
```

## 🚀 Deploy Commands

### Install

```bash
# Install básico
helm install guess-game-helm ./helm/guess-game

# Install com valores customizados
helm install guess-game-helm ./helm/guess-game \
  --set backend.replicaCount=5 \
  --set postgresql.password=novasenha

# Install com arquivo de valores
helm install guess-game-helm ./helm/guess-game \
  -f helm/guess-game/values-prod.yaml

# Install em namespace específico
helm install guess-game-helm ./helm/guess-game \
  --namespace guess-game-prod --create-namespace
```

### Upgrade

```bash
# Upgrade simples
helm upgrade guess-game-helm ./helm/guess-game

# Upgrade com novos valores
helm upgrade guess-game-helm ./helm/guess-game \
  --set global.imageRegistry=docker.io/newuser

# Upgrade forçado
helm upgrade guess-game-helm ./helm/guess-game --force

# Upgrade com rollback automático em caso de falha
helm upgrade guess-game-helm ./helm/guess-game --atomic
```

## 📋 Management Commands

### Status e Informações

```bash
# Listar releases
helm list

# Status detalhado
helm status guess-game-helm

# Histórico de revisões
helm history guess-game-helm

# Ver valores atuais
helm get values guess-game-helm

# Ver manifests gerados
helm get manifest guess-game-helm
```

### Rollback

```bash
# Rollback para versão anterior
helm rollback guess-game-helm

# Rollback para revisão específica
helm rollback guess-game-helm 2

# Ver diferenças entre revisões
helm diff revision guess-game-helm 1 2
```

### Uninstall

```bash
# Uninstall mantendo histórico
helm uninstall guess-game-helm

# Uninstall removendo tudo
helm uninstall guess-game-helm --purge
```

## ⚙️ Customização via Values

### values.yaml Principais Configurações

```yaml
# Configurações globais
global:
  namespace: guess-game
  imageRegistry: docker.io/luccasdsm

# PostgreSQL
postgresql:
  enabled: true
  password: secretpass
  persistence:
    enabled: true
    size: 2Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 250m

# Backend
backend:
  replicaCount: 3
  image:
    repository: guess-game-backend
    tag: latest
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70

# Frontend
frontend:
  replicaCount: 2
  image:
    repository: guess-game-frontend
    tag: latest
```

### Ambientes Específicos

**values-dev.yaml:**

```yaml
backend:
  replicaCount: 1
  resources:
    requests:
      memory: 128Mi
      cpu: 100m

postgresql:
  persistence:
    enabled: false

ingress:
  enabled: false
```

**values-prod.yaml:**

```yaml
backend:
  replicaCount: 5
  resources:
    requests:
      memory: 256Mi
      cpu: 200m
    limits:
      memory: 512Mi
      cpu: 500m

postgresql:
  persistence:
    enabled: true
    size: 10Gi
  resources:
    requests:
      memory: 512Mi
      cpu: 500m

ingress:
  enabled: true
  host: guess-game.production.com
```

## 🔧 Development Workflow

### Lint e Validação

```bash
# Lint do chart
helm lint helm/guess-game/

# Dry-run para validar
helm install guess-game-test ./helm/guess-game --dry-run --debug

# Template para ver output
helm template guess-game-test ./helm/guess-game

# Template com valores específicos
helm template guess-game-test ./helm/guess-game \
  -f helm/guess-game/values-prod.yaml
```

### Testing

```bash
# Test hooks (se implementados)
helm test guess-game-helm

# Verificar se deploy foi bem sucedido
kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy with Helm
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Helm
        run: |
          curl https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz | tar xz
          sudo mv linux-amd64/helm /usr/local/bin/

      - name: Deploy to Kubernetes
        run: |
          helm upgrade --install guess-game-prod ./helm/guess-game \
            --namespace production \
            --create-namespace \
            -f helm/guess-game/values-prod.yaml
```

## 📊 Monitoring

### Release Monitoring

```bash
# Ver status do release
helm status guess-game-helm

# Monitorar pods do release
kubectl get pods -l app.kubernetes.io/managed-by=Helm -w

# Ver events relacionados ao release
kubectl get events --field-selector involvedObject.kind=Pod \
  --field-selector involvedObject.namespace=guess-game
```

### Resource Tracking

```bash
# Ver recursos criados pelo Helm
kubectl get all -l app.kubernetes.io/managed-by=Helm -n guess-game

# Ver recursos com labels específicos
kubectl get all -l app.kubernetes.io/name=guess-game-k8s -n guess-game
```

## 🔒 Security Best Practices

### Secrets Management

```yaml
# No values.yaml - usar referências
postgresql:
  existingSecret: postgres-credentials
  existingSecretKey: password

# Criar secret externamente
kubectl create secret generic postgres-credentials \
  --from-literal=password=supersecret \
  -n guess-game
```

### RBAC

```yaml
# No templates/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "guess-game.serviceAccountName" . }}
  namespace: {{ .Values.global.namespace }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "guess-game.fullname" . }}-role
  namespace: {{ .Values.global.namespace }}
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
```

## 🌐 Multi-Environment Management

### Environment Structure

```
helm/
├── guess-game/              # Base chart
├── environments/
│   ├── development/
│   │   └── values.yaml
│   ├── staging/
│   │   └── values.yaml
│   └── production/
│       └── values.yaml
```

### Deploy por Ambiente

```bash
# Development
helm upgrade --install guess-game-dev ./helm/guess-game \
  -f helm/environments/development/values.yaml \
  --namespace guess-game-dev

# Staging
helm upgrade --install guess-game-staging ./helm/guess-game \
  -f helm/environments/staging/values.yaml \
  --namespace guess-game-staging

# Production
helm upgrade --install guess-game-prod ./helm/guess-game \
  -f helm/environments/production/values.yaml \
  --namespace guess-game-prod
```

## 🚨 Troubleshooting

### Problemas Comuns

**Release failed:**

```bash
# Ver status detalhado
helm status guess-game-helm

# Ver logs do último deploy
kubectl logs -l app.kubernetes.io/managed-by=Helm -n guess-game

# Rollback se necessário
helm rollback guess-game-helm
```

**Template errors:**

```bash
# Debug template generation
helm template guess-game-test ./helm/guess-game --debug

# Validar values
helm lint helm/guess-game/ --strict
```

**Values not applied:**

```bash
# Verificar valores atuais
helm get values guess-game-helm

# Comparar com values.yaml
helm get values guess-game-helm --all
```

### Debug Commands

```bash
# Ver informações completas do release
helm get all guess-game-helm

# Export manifests para debug
helm get manifest guess-game-helm > current-manifests.yaml

# Comparar revisões
helm diff revision guess-game-helm 1 2
```

## 📚 Advanced Features

### Hooks

```yaml
# Pre-install hook
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "guess-game.fullname" . }}-migration
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
```

### Tests

```yaml
# Test pod
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "guess-game.fullname" . }}-test
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: test
    image: busybox
    command: ['wget']
    args: ['{{ include "guess-game.fullname" . }}-service:5000/health']
  restartPolicy: Never
```

### Subcharts

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

## 🔗 Recursos Úteis

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Helm Hub](https://artifacthub.io/)
- [Helm Templates Guide](https://helm.sh/docs/chart_template_guide/)

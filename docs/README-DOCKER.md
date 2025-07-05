# Guess Game - Docker Compose

Este projeto implementa um jogo de adivinhação usando Docker Compose para orquestração local.

## 🚀 Quick Start

```bash
# 1. Clonar e entrar na pasta
git clone <seu-repo>
cd guess-game-docker-k8s/docker-compose

# 2. Iniciar ambiente
./scripts/start.sh

# 3. Acessar aplicação
# Abrir: http://localhost:3001
```

## 📋 Pré-requisitos

- Docker Desktop
- Git Bash (Windows) ou terminal Unix-like
- Portas livres: 3001, 5433

## 🏗️ Arquitetura

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │────│    Proxy    │────│  Frontend   │
│ :3001       │    │   NGINX     │    │   React     │
└─────────────┘    │  :3001      │    │   :3000     │
                   └─────────────┘    └─────────────┘
                          │
                   ┌─────────────┐    ┌─────────────┐
                   │   Backend   │────│ PostgreSQL  │
                   │ Flask (x3)  │    │   :5432     │
                   │   :5000     │    │             │
                   └─────────────┘    └─────────────┘
```

## 📂 Estrutura

```
docker-compose/
├── docker-compose.yml      # Configuração principal
├── .env                   # Variáveis de ambiente
└── scripts/
    ├── start.sh          # Iniciar ambiente
    ├── stop.sh           # Parar ambiente
    ├── logs.sh           # Ver logs
    ├── scale.sh          # Escalar backend
    ├── update.sh         # Atualizar serviços
    ├── backup.sh         # Backup do banco
    └── health-check.sh   # Verificar saúde
```

## 🔧 Comandos Úteis

### Gerenciamento Básico

```bash
# Iniciar
./scripts/start.sh

# Parar
./scripts/stop.sh

# Ver logs
./scripts/logs.sh [serviço]

# Status
docker-compose ps
```

### Escalabilidade

```bash
# Escalar backend para 5 instâncias
./scripts/scale.sh 5

# Verificar distribuição de carga
./scripts/health-check.sh
```

### Atualizações

```bash
# Atualizar tudo
./scripts/update.sh all

# Atualizar apenas backend
./scripts/update.sh backend

# Atualizar apenas frontend
./scripts/update.sh frontend
```

### Backup e Restore

```bash
# Fazer backup
./scripts/backup.sh

# Backups ficam em: ./backups/
```

## 🔍 Troubleshooting

### Problemas Comuns

**Porta 3001 ocupada:**

```bash
# Verificar o que está usando a porta
netstat -an | findstr :3001

# Alterar porta no .env
PROXY_PORT=3002
```

**Backend com erro 500:**

```bash
# Ver logs detalhados
./scripts/logs.sh backend

# Reiniciar apenas o backend
docker-compose restart backend
```

**PostgreSQL não conecta:**

```bash
# Verificar saúde do banco
docker-compose exec postgres pg_isready -U postgres

# Recriar banco (PERDE DADOS!)
docker-compose down -v
./scripts/start.sh
```

### Logs Importantes

```bash
# Ver todos os logs
./scripts/logs.sh

# Logs específicos
./scripts/logs.sh postgres
./scripts/logs.sh backend
./scripts/logs.sh frontend
./scripts/logs.sh proxy
```

## 🌐 URLs de Acesso

- **Aplicação Principal**: http://localhost:3001
- **PostgreSQL**: localhost:5433
  - Usuário: `postgres`
  - Senha: `secretpass`
  - Banco: `postgres`

## ⚙️ Configuração

### Variáveis de Ambiente (.env)

```bash
# Banco
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secretpass

# Portas
PROXY_PORT=3001
POSTGRES_PORT=5433

# Backend
BACKEND_REPLICAS=2

# Frontend
REACT_APP_BACKEND_URL=http://localhost:3001/api
```

### Customização

```bash
# Alterar número de backends
echo "BACKEND_REPLICAS=5" >> .env
./scripts/update.sh backend

# Alterar porta principal
echo "PROXY_PORT=8080" >> .env
docker-compose up -d proxy
```

## 🔒 Segurança

### Dados Sensíveis

- Senhas estão no `.env` - **NÃO** committar em produção
- PostgreSQL está exposto na porta 5433 - apenas para desenvolvimento
- Usar secrets em produção

### Backup

- Backups automáticos no diretório `./backups/`
- Manter apenas 5 backups mais recentes
- Testar restore periodicamente

## 📈 Performance

### Load Balancing

- 3 instâncias do backend por padrão
- NGINX distribui requisições automaticamente
- Escalar conforme necessário: `./scripts/scale.sh N`

### Monitoramento

```bash
# Verificar saúde geral
./scripts/health-check.sh

# Monitorar recursos
docker stats

# Ver conexões PostgreSQL
docker-compose exec postgres psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

## 🚀 Próximos Passos

Este ambiente está pronto para migração para Kubernetes. Ver:

- `../kubernetes/` - Manifests Kubernetes
- `../helm/` - Helm Charts
- `../images/` - Scripts para Docker Hub

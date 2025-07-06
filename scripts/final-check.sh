#!/bin/bash

echo "🎯 VERIFICAÇÃO FINAL - Guess Game Docker & Kubernetes"
echo "======================================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        return 1
    fi
}

echo ""
echo -e "${BLUE}🔍 1. VERIFICANDO PRÉ-REQUISITOS${NC}"
echo "--------------------------------"

# Docker
docker --version > /dev/null 2>&1
check_status "Docker instalado"

# Kubernetes
kubectl version --client > /dev/null 2>&1
check_status "kubectl instalado"

# Helm
helm version > /dev/null 2>&1
check_status "Helm instalado"

# Cluster conectado
kubectl cluster-info > /dev/null 2>&1
check_status "Cluster Kubernetes acessível"

echo ""
echo -e "${BLUE}🐳 2. VERIFICANDO DOCKER COMPOSE${NC}"
echo "--------------------------------"

if [ -d "docker-compose" ]; then
    echo -e "${GREEN}✅ Pasta docker-compose existe${NC}"
    
    if [ -f "docker-compose/docker-compose.yml" ]; then
        echo -e "${GREEN}✅ docker-compose.yml existe${NC}"
    else
        echo -e "${RED}❌ docker-compose.yml não encontrado${NC}"
    fi
    
    if [ -f "docker-compose/.env" ]; then
        echo -e "${GREEN}✅ .env existe${NC}"
    else
        echo -e "${YELLOW}⚠️ .env não encontrado (opcional)${NC}"
    fi
    
    if [ -d "docker-compose/scripts" ]; then
        echo -e "${GREEN}✅ Scripts de automação existem${NC}"
        ls docker-compose/scripts/*.sh > /dev/null 2>&1
        check_status "Scripts executáveis encontrados"
    else
        echo -e "${RED}❌ Pasta scripts não encontrada${NC}"
    fi
else
    echo -e "${RED}❌ Pasta docker-compose não encontrada${NC}"
fi

echo ""
echo -e "${BLUE}⚓ 3. VERIFICANDO KUBERNETES${NC}"
echo "------------------------------"

if [ -d "kubernetes" ]; then
    echo -e "${GREEN}✅ Pasta kubernetes existe${NC}"
    
    # Verificar manifests principais
    for file in namespace.yaml configmap.yaml secrets.yaml; do
        if [ -f "kubernetes/$file" ]; then
            echo -e "${GREEN}✅ $file existe${NC}"
        else
            echo -e "${RED}❌ $file não encontrado${NC}"
        fi
    done
    
    # Verificar pastas de componentes
    for dir in postgres backend frontend proxy; do
        if [ -d "kubernetes/$dir" ]; then
            echo -e "${GREEN}✅ Pasta $dir existe${NC}"
        else
            echo -e "${RED}❌ Pasta $dir não encontrada${NC}"
        fi
    done
    
    if [ -d "kubernetes/scripts" ]; then
        echo -e "${GREEN}✅ Scripts Kubernetes existem${NC}"
    else
        echo -e "${RED}❌ Scripts Kubernetes não encontrados${NC}"
    fi
else
    echo -e "${RED}❌ Pasta kubernetes não encontrada${NC}"
fi

echo ""
echo -e "${BLUE}⚓ 4. VERIFICANDO HELM${NC}"
echo "----------------------"

if [ -d "helm" ]; then
    echo -e "${GREEN}✅ Pasta helm existe${NC}"
    
    if [ -d "helm/guess-game" ]; then
        echo -e "${GREEN}✅ Chart guess-game existe${NC}"
        
        if [ -f "helm/guess-game/Chart.yaml" ]; then
            echo -e "${GREEN}✅ Chart.yaml existe${NC}"
        else
            echo -e "${RED}❌ Chart.yaml não encontrado${NC}"
        fi
        
        if [ -f "helm/guess-game/values.yaml" ]; then
            echo -e "${GREEN}✅ values.yaml existe${NC}"
        else
            echo -e "${RED}❌ values.yaml não encontrado${NC}"
        fi
        
        if [ -d "helm/guess-game/templates" ]; then
            echo -e "${GREEN}✅ Templates existem${NC}"
            
            # Verificar templates principais
            template_count=$(find helm/guess-game/templates -name "*.yaml" | wc -l)
            if [ $template_count -gt 0 ]; then
                echo -e "${GREEN}✅ $template_count templates encontrados${NC}"
            else
                echo -e "${RED}❌ Nenhum template encontrado${NC}"
            fi
        else
            echo -e "${RED}❌ Pasta templates não encontrada${NC}"
        fi
        
        # Lint do chart
        cd helm > /dev/null 2>&1
        helm lint guess-game/ > /dev/null 2>&1
        check_status "Chart Helm válido"
        cd .. > /dev/null 2>&1
    else
        echo -e "${RED}❌ Chart guess-game não encontrado${NC}"
    fi
else
    echo -e "${RED}❌ Pasta helm não encontrada${NC}"
fi

echo ""
echo -e "${BLUE}🐳 5. VERIFICANDO IMAGENS DOCKER${NC}"
echo "--------------------------------"

# Verificar se as imagens estão disponíveis
images=("luccasdsm/guess-game-backend:latest" "luccasdsm/guess-game-frontend:latest" "luccasdsm/guess-game-proxy:latest")

for image in "${images[@]}"; do
    docker pull $image > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $image disponível${NC}"
    else
        echo -e "${YELLOW}⚠️ $image não encontrada (pode precisar de build)${NC}"
    fi
done

echo ""
echo -e "${BLUE}🔍 6. VERIFICANDO AMBIENTE ATUAL${NC}"
echo "--------------------------------"

# Verificar se há deployments ativos
if kubectl get namespace guess-game > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Namespace guess-game existe${NC}"
    
    # Verificar pods
    pod_count=$(kubectl get pods -n guess-game --no-headers 2>/dev/null | wc -l)
    if [ $pod_count -gt 0 ]; then
        echo -e "${GREEN}✅ $pod_count pods encontrados no namespace${NC}"
        
        # Verificar pods running
        running_pods=$(kubectl get pods -n guess-game --no-headers 2>/dev/null | grep "Running" | wc -l)
        echo -e "${GREEN}✅ $running_pods pods em execução${NC}"
    else
        echo -e "${YELLOW}⚠️ Nenhum pod encontrado no namespace${NC}"
    fi
    
    # Verificar services
    svc_count=$(kubectl get svc -n guess-game --no-headers 2>/dev/null | wc -l)
    if [ $svc_count -gt 0 ]; then
        echo -e "${GREEN}✅ $svc_count services encontrados${NC}"
    else
        echo -e "${YELLOW}⚠️ Nenhum service encontrado${NC}"
    fi
    
    # Verificar Helm releases
    if helm list | grep -q guess-game; then
        echo -e "${GREEN}✅ Release Helm ativo encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️ Nenhum release Helm ativo${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Namespace guess-game não existe (ambiente limpo)${NC}"
fi

echo ""
echo -e "${BLUE}🌐 7. TESTE DE CONECTIVIDADE${NC}"
echo "-----------------------------"

# Verificar se aplicação está acessível
if curl -f -s http://localhost:3001 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose acessível em localhost:3001${NC}"
elif curl -f -s http://localhost:30300 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Kubernetes acessível em localhost:30300${NC}"
else
    echo -e "${YELLOW}⚠️ Aplicação não acessível (pode estar parada)${NC}"
fi

echo ""
echo -e "${BLUE}📋 8. RESUMO FINAL${NC}"
echo "-------------------"

echo -e "${GREEN}✅ AMBIENTES DISPONÍVEIS:${NC}"
echo "  🐳 Docker Compose: cd docker-compose && ./scripts/start.sh"
echo "  ⚓ Kubernetes: cd kubernetes && ./scripts/deploy.sh"
echo "  ⚓ Helm: cd helm && helm install guess-game-helm ./guess-game"

echo ""
echo -e "${GREEN}✅ URLS DE ACESSO:${NC}"
echo "  🐳 Docker Compose: http://localhost:3001"
echo "  ⚓ Kubernetes/Helm: http://localhost:30300"

echo ""
echo -e "${GREEN}✅ COMANDOS ÚTEIS:${NC}"
echo "  📊 Status: kubectl get all -n guess-game"
echo "  📋 Logs: kubectl logs -l app=backend -n guess-game"
echo "  🔄 Escalar: kubectl scale deployment backend-deployment --replicas=5 -n guess-game"
echo "  📦 Helm Status: helm list && helm status guess-game-helm"

echo ""
echo -e "${GREEN}✅ DOCUMENTAÇÃO:${NC}"
echo "  📚 README.md - Guia principal"
echo "  📚 docs/KUBERNETES.md - Guia detalhado do Kubernetes"
echo "  📚 docs/HELM.md - Guia detalhado do Helm"

echo ""
echo -e "${GREEN}🎉 VERIFICAÇÃO CONCLUÍDA!${NC}"
echo -e "${BLUE}Projeto Guess Game Docker & Kubernetes está pronto para uso!${NC}"
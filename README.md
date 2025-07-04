# Jogo de Adivinhação com Flask

Este é um simples jogo de adivinhação desenvolvido utilizando o framework Flask. O jogador deve adivinhar uma senha criada aleatoriamente, e o sistema fornecerá feedback sobre o número de letras corretas e suas respectivas posições.

## Funcionalidades

- Criação de um novo jogo com uma senha fornecida pelo usuário.
- Adivinhe a senha e receba feedback se as letras estão corretas e/ou em posições corretas.
- As senhas são armazenadas utilizando base64.
- As adivinhações incorretas retornam uma mensagem com dicas.

## Implementação Docker (NOVA VERSÃO)

Esta versão foi evoluída para rodar com Docker Compose, implementando uma arquitetura de microserviços production-ready.

### Melhorias implementadas

- **Load Balancing**: 3 instâncias do backend para alta disponibilidade
- **Proxy Reverso NGINX**: Roteamento e cache otimizados
- **Redes Isoladas**: Segurança através de network separation
- **Volumes Persistentes**: Dados seguros e cache performance
- **Health Checks**: Monitoramento automático dos serviços
- **Auto-restart**: Recuperação automática em falhas

### Por que pasta backend/ separada?

A estrutura `backend/dockerfile` foi criada para:

- **Build Context Isolation**: Cada serviço tem seu contexto de build independente
- **Facilita Updates**: Posso atualizar cada container separadamente
- **CI/CD Ready**: Estrutura preparada para pipelines automatizados
- **Multi-environment**: Suporte fácil para diferentes ambientes (dev/prod)

### Arquitetura de Redes

- **backend-network (internal)**: Comunicação segura backend ↔ database
- **frontend-network**: Acesso público via proxy NGINX

### Estratégia de Volumes

- **postgres_data**: Persistência dos dados do jogo
- **nginx_cache**: Cache para performance do proxy

## Instalação Docker (Recomendada)

### Pré-requisitos

- Docker Desktop ou Docker + Docker Compose

### Instalação

1. Clone o repositório:

   ```bash
   git clone https://github.com/fams/guess_game.git
   cd guess_game
   ```

2. Execute com Docker Compose:

   ```bash
   docker-compose up -d
   ```

3. Acesse a aplicação:
   ```
   http://localhost:8080
   ```

### Comandos úteis

```bash
# Ver status dos serviços
docker-compose ps

# Ver logs
docker-compose logs

# Parar serviços
docker-compose down

# Atualizar apenas backend
docker-compose build backend
docker-compose up -d backend
```

## Instalação Manual (Desenvolvimento)

### Requisitos

- Python 3.8+
- Flask
- Um banco de dados local (ou um mecanismo de armazenamento configurado em `current_app.db`)
- node 18.17.0

### Instalação

1. Clone o repositório:

   ```bash
   git clone https://github.com/Luccas-dsm/guess_game_docker
   cd guess-game
   ```

2. Crie um ambiente virtual e ative-o:

   ```bash
   python3 -m venv venv
   source venv/bin/activate  # Linux/Mac
   venv\Scripts\activate  # Windows
   ```

3. Instale as dependências:

   ```bash
   pip install -r requirements.txt
   ```

4. Configure o banco de dados com as variáveis de ambiente no arquivo start-backend.sh

   1. Para sqlite

      ```bash
          export FLASK_APP="run.py"
          export FLASK_DB_TYPE="sqlite"            # Use SQLITE
          export FLASK_DB_PATH="caminho/db.sqlite" # caminho do banco
      ```

   2. Para Postgres

      ```bash
          export FLASK_APP="run.py"
          export FLASK_DB_TYPE="postgres"       # Use postgres
          export FLASK_DB_USER="postgres"       # Usuário do banco
          export FLASK_DB_NAME="postgres"       # Nome do Banco
          export FLASK_DB_PASSWORD="secretpass" # Senha do banco
          export FLASK_DB_HOST="localhost"      # Hostname
          export FLASK_DB_PORT="5432"           # Porta
      ```

   3. Para DynamoDB

      ```bash
      export FLASK_APP="run.py"
      export FLASK_DB_TYPE="dynamodb"       # Use postgres
      export AWS_DEFAULT_REGION="us-east-1" # AWS region
      export AWS_ACCESS_KEY_ID="FAKEACCESSKEY123456"
      export AWS_SECRET_ACCESS_KEY="FakeSecretAccessKey987654321"
      export AWS_SESSION_TOKEN="FakeSessionTokenABCDEFGHIJKLMNOPQRSTUVXYZ1234567890"
      ```

5. Execute o backend

   ```bash
   ./start-backend.sh &
   ```

6. Cuidado! verifique se o seu linux está lendo o arquivo .sh com fim de linha do windows CRLF. Para verificar utilize o vim -b start-backend.sh

## Frontend

No diretorio de frontend

1. Instale o node com o nvm. Se não tiver o nvm instalado, siga o [tutorial](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating)

   ```bash
   nvm install 18.17.0
   nvm use 18.17.0
   # Habilite o yarn
   corepack enable
   ```

2. Instale as dependências do node com o npm:

   ```bash
   npm install
   ```

3. Exporte a url onde está executando o backend e execute o backend.

   ```bash
    export REACT_APP_BACKEND_URL=http://localhost:5000
    yarn start
   ```

## Como Jogar

### 1. Criar um novo jogo

Acesse a url do frontend http://localhost:3000 (desenvolvimento) ou http://localhost:8081 (Docker)

Digite uma frase secreta

Envie

Salve o game-id

### 2. Adivinhar a senha

Acesse a url do frontend http://localhost:3000 (desenvolvimento) ou http://localhost:8081 (Docker)

Vá para o endponint breaker

entre com o game_id que foi gerado pelo Creator

Tente adivinhar

## Atualizações de Componentes (Docker)

### Backend

```bash
docker-compose build backend
docker-compose up -d backend
```

### Frontend

```bash
docker-compose build frontend
docker-compose up -d frontend
```

### NGINX

```bash
docker-compose build nginx
docker-compose up -d nginx
```

### Database

```bash
# Edite a versão no docker-compose.yml
docker-compose up -d postgres
```

## Estrutura do Código

### Rotas:

- **`/create`**: Cria um novo jogo. Armazena a senha codificada em base64 e retorna um `game_id`.
- **`/guess/<game_id>`**: Permite ao usuário adivinhar a senha. Compara a adivinhação com a senha armazenada e retorna o resultado.

### Classes Importantes:

- **`Guess`**: Classe responsável por gerenciar a lógica de comparação entre a senha e a tentativa do jogador.
- **`WrongAttempt`**: Exceção personalizada que é levantada quando a tentativa está incorreta.

## Melhorias Futuras

- Implementar autenticação de usuário para salvar e carregar jogos.
- Adicionar limite de tentativas.
- Melhorar a interface de feedback para as tentativas de adivinhação.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

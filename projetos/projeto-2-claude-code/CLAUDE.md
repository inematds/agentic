# CLAUDE.md — API REST de Gerenciamento de Tarefas

Este arquivo configura o comportamento do Claude Code neste projeto. Leia com atenção antes de executar qualquer ação.

---

## Contexto do Projeto

Este projeto é uma **API REST** para gerenciamento de tarefas (to-do list) construída com **Python 3.11** e **FastAPI**. A API permite criar, listar, atualizar e deletar tarefas, com autenticação JWT, banco de dados PostgreSQL via SQLAlchemy e documentação automática via Swagger.

**Stack principal:**
- Python 3.11
- FastAPI 0.111
- SQLAlchemy 2.0 (ORM)
- PostgreSQL 15
- Alembic (migrations)
- Pydantic v2 (validação de dados)
- pytest (testes)
- Docker / Docker Compose

**Repositório:** `github.com/nmaldaner/task-api`
**Branch principal:** `main`
**Branch de desenvolvimento:** `develop`

---

## Comandos de Desenvolvimento

### Instalação

```bash
# Clonar e entrar no projeto
git clone https://github.com/nmaldaner/task-api.git
cd task-api

# Criar e ativar ambiente virtual
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows

# Instalar dependências
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### Rodar o Projeto

```bash
# Subir banco de dados com Docker
docker compose up -d postgres

# Rodar migrations
alembic upgrade head

# Iniciar servidor de desenvolvimento
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Iniciar com configurações de produção
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

### Testes

```bash
# Rodar todos os testes
pytest

# Rodar com cobertura
pytest --cov=app --cov-report=html

# Rodar apenas testes de um módulo específico
pytest tests/test_tasks.py -v

# Rodar testes marcados como unitários
pytest -m unit

# Rodar testes e parar no primeiro erro
pytest -x
```

### Migrations

```bash
# Criar nova migration
alembic revision --autogenerate -m "descricao_da_mudanca"

# Aplicar todas as migrations
alembic upgrade head

# Reverter última migration
alembic downgrade -1

# Ver histórico de migrations
alembic history
```

### Outros Comandos Úteis

```bash
# Lint e formatação
ruff check app/
ruff format app/
mypy app/

# Verificar tipos
mypy app/ --strict

# Gerar requirements.txt atualizado
pip freeze > requirements.txt
```

---

## Convenções de Código

### Nomenclatura

- **Variáveis e funções:** `snake_case` — ex: `get_user_tasks`, `task_id`
- **Classes:** `PascalCase` — ex: `TaskCreate`, `UserResponse`
- **Constantes:** `UPPER_SNAKE_CASE` — ex: `MAX_TASKS_PER_PAGE`, `DEFAULT_TIMEOUT`
- **Arquivos:** `snake_case.py` — ex: `task_router.py`, `auth_service.py`
- **Endpoints:** kebab-case na URL — ex: `/api/v1/user-tasks`

### Type Hints

Todo o código DEVE usar type hints. Use o módulo `typing` quando necessário.

```python
# CORRETO
def get_task(task_id: int, db: Session) -> TaskResponse | None:
    ...

# ERRADO — sem type hints
def get_task(task_id, db):
    ...
```

### Docstrings

Use o formato Google Style para docstrings em todas as funções públicas:

```python
def create_task(task_data: TaskCreate, db: Session) -> TaskResponse:
    """Cria uma nova tarefa no banco de dados.

    Args:
        task_data: Dados da tarefa a ser criada, validados pelo Pydantic.
        db: Sessão do banco de dados injetada pelo FastAPI.

    Returns:
        TaskResponse com os dados da tarefa criada, incluindo o ID gerado.

    Raises:
        HTTPException: Se o usuário não tiver permissão ou os dados forem inválidos.
    """
    ...
```

### Organização de Imports

Siga a ordem: stdlib > third-party > local, separados por linha em branco:

```python
# 1. Stdlib
from datetime import datetime
from typing import Optional

# 2. Third-party
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

# 3. Local
from app.database import get_db
from app.models.task import Task
from app.schemas.task import TaskCreate, TaskResponse
```

### Tratamento de Erros

Sempre use `HTTPException` do FastAPI com status codes semânticos:

```python
raise HTTPException(
    status_code=404,
    detail="Tarefa não encontrada"
)
```

---

## Regras de Comportamento do Claude Code

### Git e Versionamento

- **NUNCA commitar diretamente para `main` ou `develop`**
- Sempre criar uma branch descritiva antes de qualquer mudança: `feat/descricao`, `fix/descricao`, `refactor/descricao`
- Mensagens de commit em português, no imperativo: "Adiciona endpoint de listagem", "Corrige bug no filtro de datas"
- Sempre rodar os testes antes de commitar: `pytest`
- Nunca usar `git push --force` — se necessário, perguntar ao usuário

### Criação de Branches

```bash
# Para novas features
git checkout -b feat/nome-da-feature

# Para correções de bug
git checkout -b fix/descricao-do-bug

# Para refatorações
git checkout -b refactor/descricao
```

### Ao Modificar Código

1. Sempre ler o arquivo completo antes de editar
2. Não remover comentários existentes sem motivo explícito
3. Manter o estilo de código já presente no arquivo
4. Após editar qualquer arquivo Python, rodar: `ruff check app/` para verificar lint
5. Após modificar modelos ou schemas, verificar se as migrations precisam ser atualizadas

### Ao Criar Novos Arquivos

- Novos routers devem ser registrados em `app/main.py`
- Novos modelos devem herdar de `Base` em `app/database.py`
- Novos schemas devem seguir o padrão `NomeCreate`, `NomeUpdate`, `NomeResponse`
- Todo novo arquivo deve ter testes correspondentes em `tests/`

### Nunca Fazer

- Nunca expor a `SECRET_KEY` ou `DATABASE_URL` em código
- Nunca remover arquivos de migration já aplicados
- Nunca fazer `DROP TABLE` ou `DELETE FROM` sem confirmação explícita do usuário
- Nunca instalar dependências sem adicionar ao `requirements.txt`
- Nunca alterar arquivos de configuração de produção sem avisar o usuário

---

## Arquitetura do Projeto

```
task-api/
├── app/
│   ├── __init__.py
│   ├── main.py               # Entry point, registro de routers
│   ├── database.py           # Configuração do SQLAlchemy, get_db()
│   ├── config.py             # Settings via pydantic-settings
│   ├── dependencies.py       # Dependências compartilhadas (auth, etc.)
│   │
│   ├── models/               # Modelos SQLAlchemy (tabelas do banco)
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── task.py
│   │
│   ├── schemas/              # Schemas Pydantic (request/response)
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── task.py
│   │
│   ├── routers/              # Endpoints organizados por recurso
│   │   ├── __init__.py
│   │   ├── auth.py           # /api/v1/auth/*
│   │   ├── users.py          # /api/v1/users/*
│   │   └── tasks.py          # /api/v1/tasks/*
│   │
│   └── services/             # Lógica de negócio
│       ├── __init__.py
│       ├── auth_service.py
│       └── task_service.py
│
├── tests/
│   ├── conftest.py           # Fixtures compartilhadas
│   ├── test_auth.py
│   ├── test_users.py
│   └── test_tasks.py
│
├── migrations/               # Alembic migrations
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│
├── .env.example              # Template de variáveis de ambiente
├── .env                      # Variáveis locais (NÃO commitar)
├── alembic.ini
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
└── CLAUDE.md                 # Este arquivo
```

---

## Variáveis de Ambiente

Copie `.env.example` para `.env` antes de rodar o projeto. O arquivo `.env` nunca deve ser commitado.

```bash
# Banco de dados
DATABASE_URL=postgresql://user:password@localhost:5432/taskdb
DATABASE_URL_TEST=postgresql://user:password@localhost:5432/taskdb_test

# Segurança
SECRET_KEY=your-super-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Aplicação
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=info
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173

# Opcionais
SENTRY_DSN=
REDIS_URL=redis://localhost:6379/0
```

---

## URLs e Endpoints Principais

**Documentação interativa (Swagger):** http://localhost:8000/docs
**Documentação alternativa (ReDoc):** http://localhost:8000/redoc
**Health check:** http://localhost:8000/health

### Endpoints da API

| Método | Endpoint                    | Descrição                          |
|--------|-----------------------------|------------------------------------|
| POST   | /api/v1/auth/register       | Registrar novo usuário             |
| POST   | /api/v1/auth/login          | Autenticar e obter JWT             |
| GET    | /api/v1/users/me            | Dados do usuário autenticado       |
| GET    | /api/v1/tasks               | Listar tarefas do usuário          |
| POST   | /api/v1/tasks               | Criar nova tarefa                  |
| GET    | /api/v1/tasks/{id}          | Buscar tarefa por ID               |
| PATCH  | /api/v1/tasks/{id}          | Atualizar tarefa parcialmente      |
| DELETE | /api/v1/tasks/{id}          | Deletar tarefa                     |
| PATCH  | /api/v1/tasks/{id}/complete | Marcar tarefa como concluída       |

### Autenticação

Todos os endpoints (exceto `/auth/*` e `/health`) requerem o header:

```
Authorization: Bearer <seu-jwt-token>
```

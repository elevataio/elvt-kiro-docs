# Kiro + Servicos AWS Backend: Guia Pratico

> Guia para equipes que desejam implantar o Kiro com servicos de backend AWS. Escrito para tomadores de decisao nao-tecnicos e usuarios iniciantes que querem aproveitar ao maximo o fluxo de desenvolvimento com IA do Kiro.

---

## Sumario

1. [O que e o Kiro?](#o-que-e-o-kiro)
2. [Primeiros Passos](#primeiros-passos)
3. [Steering Files — Ensinando Seus Padroes ao Kiro](#steering-files)
4. [Hooks — Automatizando Seu Fluxo de Trabalho](#hooks)
5. [Specs — Desenvolvimento Estruturado](#specs)
6. [Servidores MCP — Estendendo as Capacidades do Kiro](#servidores-mcp)
7. [Integracao com AWS Bedrock](#integracao-aws-bedrock)
8. [Implantando Infraestrutura AWS com o Kiro](#implantando-infraestrutura)
9. [Governanca Empresarial e Seguranca](#governanca-empresarial)
10. [Deploy com Um Clique — Template CloudFormation](#cloudformation-deployment)
11. [Resumo de Boas Praticas](#boas-praticas)
12. [Links de Referencia](#links-de-referencia)

---

## O que e o Kiro? <a name="o-que-e-o-kiro"></a>

O Kiro e um ambiente de desenvolvimento com inteligencia artificial, criado pela AWS, que ajuda a construir software do prototipo a producao. Ele transforma comandos em linguagem natural em especificacoes estruturadas e codigo funcional.

O Kiro esta disponivel em multiplas interfaces:

| Interface | Descricao |
|-----------|-----------|
| **IDE** | Aplicativo desktop baseado no VS Code |
| **CLI** | Interface de linha de comando para fluxos no terminal |
| **Web** | Desenvolvimento no navegador (conectado ao GitHub/GitLab) |
| **Mobile** | Acesso em dispositivos moveis |
| **Crew** | Agente pessoal de IA rodando localmente |

A principal vantagem: sua configuracao, specs, steering files e hooks funcionam de forma identica em todas as interfaces. Comece uma feature no IDE, continue pelo CLI, passe para o agente Web — tudo permanece sincronizado.

### Conceitos-Chave

- **Steering Files** — Instrucoes persistentes que informam o Kiro sobre as convencoes do seu projeto
- **Hooks** — Acoes automatizadas disparadas por eventos (salvamento de arquivos, chamadas de ferramentas, etc.)
- **Specs** — Fluxo de desenvolvimento estruturado: Requisitos → Design → Tarefas
- **Servidores MCP** — Ferramentas e servicos externos que o Kiro pode utilizar
- **Powers** — Pacotes com documentacao, guias de fluxo e servidores MCP
- **Agentes Customizados** — Configuracoes especializadas do Kiro para tarefas especificas

---

## Primeiros Passos <a name="primeiros-passos"></a>

### Pre-requisitos

- **Uma conta AWS com metodo de pagamento valido (cartao de credito obrigatorio)** — A cobranca do Kiro vai diretamente na sua conta AWS. Mesmo o tier gratuito requer conta AWS para uso empresarial.
- Kiro instalado a partir de [kiro.dev](https://kiro.dev/docs/getting-started/installation/)
- Credenciais AWS configuradas (`aws configure`) se voce planeja implantar infraestrutura

> **Importante**: Para uso individual, voce pode fazer login com GitHub ou Google sem conta AWS. Porem, para implantacao empresarial/equipe com controle de cobranca e recursos de governanca, uma conta AWS e obrigatoria, pois todas as cobracas aparecem na sua fatura AWS.

### Habilitando o Kiro na Sua Conta AWS (Cobranca e Assinatura)

Antes da equipe usar o Kiro, um administrador deve habilitar o servico no Console AWS. E aqui que o controle de cobranca esta.

#### Passo 1: Habilitar o IAM Identity Center

1. Escolha a [regiao AWS suportada pelo Kiro](https://kiro.dev/docs/enterprise/getting-started/) para o Identity Center
2. Navegue ate **IAM Identity Center** no Console AWS
3. Clique em **Enable**
4. Adicione seus usuarios na secao Users
5. (Opcional) Configure MFA em Settings → Authentication

> O IAM Identity Center e oferecido sem custo adicional.

#### Passo 2: Habilitar o Kiro no Console AWS

1. Navegue ate o **Console do Kiro** dentro da AWS
2. Clique em **Onboard your team to Kiro** ou **Enable small teams**
3. Quando solicitado a fonte de identidade, selecione **IAM Identity Center**
4. Verifique a configuracao do Identity Center
5. Clique em **Enable** para ativar o Kiro na sua conta AWS
6. Anote a **Sign in URL** — seus usuarios precisarao dela

#### Passo 3: Assinar Usuarios e Controlar Cobranca

1. No Console do Kiro, va ate **Users & Groups**
2. Clique em **Add user** ou **Add group**
3. Selecione o usuario ou grupo do IdC que voce criou
4. Escolha o tier de assinatura:

| Tier | Custo | Creditos/Mes | Melhor Para |
|------|-------|-------------|-------------|
| **Free** | $0 | 50 | Avaliacao, exploracao leve |
| **Pro** | $20/mes | 1.000 | Desenvolvedores individuais |
| **Pro+** | $40/mes | 2.000+ | Equipes de desenvolvimento ativas |
| **Pro Max** | $100/mes | 4.000+ | Uso intenso, multiplos projetos |
| **Power** | $200/mes | 10.000 | Usuarios power enterprise |

#### Boas Praticas de Controle de Cobranca

- **Todas as cobracas aparecem na sua fatura AWS** — use o AWS Cost Explorer para acompanhar gastos com Kiro
- **Configure alertas no AWS Budgets** — crie alertas de orcamento para o servico `kiro` para evitar surpresas
- **Use tags de alocacao de custos** — etiquete usuarios por equipe para relatorios de chargeback
- **Evite assinaturas duplicadas** — um usuario inscrito em duas regioes AWS e cobrado duas vezes
- **Para parar a cobranca** — remova o usuario do grupo inscrito ou remova a assinatura individual
- **Use SCPs (Service Control Policies)** — restrinja quais contas AWS ou OUs podem habilitar assinaturas Kiro

#### Login dos Usuarios

Uma vez habilitado, os usuarios se conectam a sua organizacao pelo aplicativo Kiro:

1. No Kiro, clique em **Sign in via IAM Identity Center**
2. Insira a **Sign in URL** do seu Console Kiro
3. Insira o **codigo da regiao AWS** correto
4. Autentique-se pelo portal de login do Identity Center
5. Clique em **Allow Access**

> **Fonte**: [Habilitar assinatura enterprise do Kiro com IAM Identity Center](https://repost.aws/articles/AR3YUupHzQQ2mqMzL5Y8KvbQ/enable-kiro-enterprise-subscription-with-iam-identity-center-in-your-aws-accounts)

### Instalacao

O Kiro esta disponivel para Mac, Windows e Linux. Baixe em [kiro.dev](https://kiro.dev) e instale como qualquer aplicativo padrao.

Apos a instalacao:

1. Abra o Kiro
2. Faca login com o **IAM Identity Center da sua organizacao** (enterprise) ou AWS Builder ID / Google / GitHub (individual)
3. Abra a pasta do seu projeto (File → Open Folder)
4. Inicie uma conversa com o agente de IA

### Primeiros Passos

Ao abrir o Kiro, voce estara em uma sessao com o agente padrao — um assistente de codificacao de proposito geral. Voce pode:

- **Sessoes Vibe** — Conversa livre, perguntas e respostas, codificacao exploratoria
- **Sessoes Spec** — Fluxo estruturado: requisitos → design → tarefas de implementacao

Para seu primeiro projeto, recomendamos seguir o [guia oficial de primeiro projeto](https://kiro.dev/docs/getting-started/first-project/).

---

## Steering Files — Ensinando Seus Padroes ao Kiro <a name="steering-files"></a>

Steering files dao ao Kiro conhecimento persistente sobre seu projeto. Em vez de explicar suas convencoes em cada conversa, os steering files garantem que o Kiro siga consistentemente seus padroes, bibliotecas e normas estabelecidas.

### O Que Sao Steering Files?

Sao arquivos Markdown simples armazenados em `.kiro/steering/` dentro do seu projeto. Pense neles como um "manual do projeto" que o Kiro le antes de executar qualquer trabalho.

### Onde Ficam

```
seu-projeto/
├── .kiro/
│   └── steering/
│       ├── visao-geral-projeto.md
│       ├── padroes-codigo.md
│       ├── convencoes-aws.md
│       └── regras-deploy.md
├── src/
└── ...
```

### Modos de Inclusao

Os steering files suportam tres modos de inclusao:

| Modo | Quando Carregado | Caso de Uso |
|------|-----------------|-------------|
| **Always** (padrao) | Toda sessao automaticamente | Convencoes do projeto, regras de arquitetura |
| **File Match** | Quando um arquivo correspondente e lido | Regras por linguagem, guias de modulo |
| **Manual** | Apenas quando o usuario inclui via referencia `#` | Docs de referencia, specs de API |

#### Inclusao Automatica (Padrao)

```markdown
# Convencoes do Projeto

- Use Python 3.12 para todos os servicos backend
- Todas as funcoes Lambda devem incluir tratamento de erros e logging no CloudWatch
- Use AWS CDK (Python) para infraestrutura como codigo
- Siga o AWS Well-Architected Framework
```

#### Condicional (File Match)

Adicione uma secao front-matter para ativar apenas quando arquivos relevantes forem abertos:

```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*.py"
---

# Padroes Python

- Use type hints em todas as assinaturas de funcao
- Formate com black, lint com ruff
- Todos os modulos devem ter docstrings
```

#### Inclusao Manual

```markdown
---
inclusion: manual
---

# Referencia da Especificacao da API

Este documento descreve o contrato da API REST...
```

Usuarios ativam steering manual no chat digitando `#` e selecionando o arquivo.

### Incluindo Arquivos Externos no Steering

Steering files podem referenciar outros arquivos do projeto usando uma sintaxe especial:

```markdown
# Guia de Implementacao da API

Siga a spec OpenAPI definida aqui:
#[[file:docs/openapi.yaml]]

Todas as implementacoes devem seguir este contrato.
```

Isso e poderoso para manter o Kiro alinhado com suas especificacoes existentes (OpenAPI, schemas GraphQL, modulos Terraform, etc.) sem duplicar conteudo.

### Steering Global (Nivel de Usuario)

Voce tambem pode definir steering que se aplica a TODOS os seus projetos colocando arquivos em:

```
~/.kiro/steering/
```

Util para preferencias pessoais como estilo de codigo preferido, formato de mensagem de commit ou ferramentas que voce sempre usa.

### Exemplo Pratico: Steering para Projeto AWS

Aqui esta um steering file completo para um projeto focado em AWS:

```markdown
# Padroes do Projeto Backend AWS

## Arquitetura
- Serverless-first: preferir Lambda + API Gateway + DynamoDB
- Usar AWS CDK (Python) para todas as definicoes de infraestrutura
- Um stack CDK por contexto delimitado (auth, api, data, monitoring)
- Cada construct customizado fica em seu proprio arquivo, nomeado com o nome do construct

## Seguranca
- Todas as funcoes Lambda rodam com roles IAM de menor privilegio
- Secrets armazenados no AWS Secrets Manager, nunca em variaveis de ambiente
- Habilitar criptografia em repouso para todos os armazens de dados
- API Gateway deve exigir autenticacao (Cognito ou IAM)

## Convencoes de Nomenclatura
- Nomes de stacks CDK: `{projeto}-{env}-{contexto}` (ex: `meuapp-prod-api`)
- Nomes de funcoes Lambda: `{projeto}-{env}-{acao}` (ex: `meuapp-prod-processarPedido`)
- Nomes de buckets S3: `{org}-{projeto}-{env}-{proposito}`

## Deploy
- Todas as mudancas passam por CDK Pipelines
- Dev → Staging → Production (promocao)
- Nunca fazer deploy direto em producao sem aprovacao do pipeline
```

> **Fonte**: Documentacao de Steering em [kiro.dev/docs/steering/](https://kiro.dev/docs/steering/)

---

## Hooks — Automatizando Seu Fluxo de Trabalho <a name="hooks"></a>

Hooks executam comandos shell ou prompts de agente automaticamente quando eventos especificos ocorrem na sua sessao. Voce define o gatilho e a acao; o Kiro cuida da execucao.

### O Que Sao Hooks?

Hooks sao arquivos de configuracao JSON armazenados em `.kiro/hooks/`. Eles automatizam tarefas repetitivas como:

- Executar linters ao salvar um arquivo
- Validar mudancas de infraestrutura antes de aplica-las
- Rodar testes apos completar uma tarefa do spec
- Injetar contexto quando uma sessao inicia

### Onde Ficam

```
seu-projeto/
├── .kiro/
│   └── hooks/
│       ├── lint-ao-salvar.json
│       ├── testar-apos-tarefa.json
│       └── verificacao-seguranca.json
```

### Estrutura do Hook

Cada arquivo de hook segue este formato:

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Nome legivel por humanos",
      "trigger": "NomeDoGatilho",
      "matcher": "padrao-regex-opcional",
      "action": {
        "type": "command",
        "command": "comando shell a executar"
      }
    }
  ]
}
```

### Gatilhos Disponiveis

| Gatilho | Quando Dispara | Uso Comum |
|---------|----------------|-----------|
| `PostFileSave` | Apos um arquivo ser salvo | Linting, formatacao, validacao |
| `PostFileCreate` | Quando um novo arquivo e criado | Verificacoes de scaffolding |
| `PostFileDelete` | Quando um arquivo e deletado | Limpeza de recursos relacionados |
| `PreToolUse` | Antes do agente usar uma ferramenta | Controle de acesso, gates de seguranca |
| `PostToolUse` | Apos uma ferramenta ser executada | Logging, notificacoes |
| `SessionStart` | Quando uma nova sessao comeca | Carregar contexto, verificar ambiente |
| `PreTaskExec` | Antes de uma tarefa spec comecar | Validacao, verificacao de dependencias |
| `PostTaskExec` | Apos uma tarefa spec completar | Rodar testes, atualizar docs |
| `UserPromptSubmit` | Quando usuario envia mensagem | Validacao de input, roteamento |
| `Stop` | Quando execucao do agente completa | Limpeza, geracao de resumo |

### Tipos de Acao

**Command** — Executa um comando shell:

```json
{
  "type": "command",
  "command": "npm run lint -- --fix"
}
```

**Agent** — Injeta um prompt no contexto da IA:

```json
{
  "type": "agent",
  "prompt": "Antes de fazer alteracoes, verifique se segue nossa baseline de seguranca AWS."
}
```

### Matcher (Opcional)

O matcher e um padrao regex que filtra quais eventos disparam o hook:

- Para `PostFileSave` / `PostFileCreate` / `PostFileDelete`: testado contra o caminho do arquivo
- Para `PreToolUse` / `PostToolUse`: testado contra o nome da ferramenta

### Exemplos Praticos

#### 1. Lint TypeScript ao Salvar

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Lint TypeScript ao Salvar",
      "trigger": "PostFileSave",
      "matcher": "\\.(ts|tsx)$",
      "action": {
        "type": "command",
        "command": "npx eslint --fix"
      }
    }
  ]
}
```

#### 2. Executar CDK Synth Apos Mudancas de Infraestrutura

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Validar Stack CDK",
      "trigger": "PostFileSave",
      "matcher": "infra/.*\\.py$",
      "action": {
        "type": "command",
        "command": "cd infra && cdk synth --quiet"
      }
    }
  ]
}
```

#### 3. Rodar Testes Apos Completar Tarefa do Spec

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Rodar Testes Apos Tarefa",
      "trigger": "PostTaskExec",
      "action": {
        "type": "command",
        "command": "npm run test"
      }
    }
  ]
}
```

#### 4. Gate de Seguranca para Operacoes de Escrita

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Revisao de Seguranca em Escritas",
      "trigger": "PreToolUse",
      "matcher": "fs_write|str_replace|fs_append",
      "action": {
        "type": "agent",
        "prompt": "Antes de escrever este arquivo, verifique: 1) Nenhum segredo ou credencial esta sendo hardcoded, 2) A mudanca segue nosso principio de menor privilegio IAM, 3) Nenhum dado sensivel e exposto em logs."
      }
    }
  ]
}
```

#### 5. Carregar Contexto AWS no Inicio da Sessao

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Carregar Info do Ambiente AWS",
      "trigger": "SessionStart",
      "action": {
        "type": "command",
        "command": "echo \"Conta AWS: $(aws sts get-caller-identity --query Account --output text), Regiao: $(aws configure get region)\""
      }
    }
  ]
}
```

### Comportamento do Codigo de Saida

Para hooks do tipo command:

| Codigo de Saida | Significado |
|----------------|-------------|
| `0` | Sucesso — output e encaminhado ao agente |
| `2` | Bloquear a acao (apenas para gatilhos Pre*) — stderr e encaminhado |
| Outro | Falha silenciosa, sem bloqueio |

### Criando Hooks

Voce pode criar hooks de tres formas:

1. **Pedir ao Kiro** — Descreva o que voce quer no chat e o Kiro gera o hook
2. **Hook UI** — Use a Paleta de Comandos → "Open Kiro Hook UI"
3. **Manual** — Crie arquivos JSON diretamente em `.kiro/hooks/`

> **Fonte**: Documentacao de Hooks em [kiro.dev/docs/hooks/](https://kiro.dev/docs/hooks/)

---

## Specs — Desenvolvimento Estruturado <a name="specs"></a>

Specs fornecem uma abordagem sistematica para construir features. Em vez de conversas nao-estruturadas, os Specs guiam voce por um processo formal: Requisitos → Design → Tarefas de Implementacao.

### Por Que Usar Specs?

- Reduz ambiguidade antes de comecar a codificar
- Cria documentacao como subproduto do desenvolvimento
- Garante que a IA entende o contexto completo antes de escrever codigo
- Fornece progresso rastreavel durante a implementacao

### O Fluxo do Spec

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Requisitos    │ ──> │    Design    │ ──> │     Tarefas     │
│                 │     │              │     │                 │
│ - User stories  │     │ - Componentes│     │ - Implementar X │
│ - Restricoes    │     │ - Modelo dados│    │ - Add testes    │
│ - Casos borda   │     │ - Design API │     │ - Config deploy │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

1. **Requisitos** — O Kiro faz perguntas de esclarecimento, depois gera requisitos detalhados
2. **Design** — Design tecnico baseado nos requisitos (componentes, fluxo de dados, APIs)
3. **Tarefas** — Tarefas de implementacao acionaveis que o Kiro executara

### Tipos de Spec

| Tipo | Quando Usar |
|------|-------------|
| **Feature Spec** | Construir nova funcionalidade do zero |
| **Bug Fix Spec** | Investigar e corrigir problemas sistematicamente |
| **Quick Spec** | Geracao rapida de requisitos + design + tarefas |

### Usando Specs com Projetos AWS

Ao construir servicos backend AWS, os Specs se destacam porque:

1. Forcam voce a pensar em permissoes IAM antes de codificar
2. Documentam o design da infraestrutura (stacks CDK, funcoes Lambda, rotas de API)
3. Dividem o deploy em etapas seguras e revisaveis
4. Criam uma trilha de auditoria clara de decisoes

### Exemplo: Criando um Spec para uma Feature de API

Inicie uma sessao Spec e descreva sua feature:

> "Preciso de um endpoint REST API que aceite uploads de arquivo, armazene no S3, dispare uma funcao Lambda para processar o arquivo e armazene metadados no DynamoDB."

O Kiro entao ira:
1. Fazer perguntas de esclarecimento (limite de tamanho? autenticacao? politica de retry?)
2. Gerar requisitos (funcionais + nao-funcionais)
3. Propor um design tecnico (stack CDK, handler Lambda, config de evento S3)
4. Criar tarefas de implementacao que voce pode aprovar e executar uma por uma

### Boas Praticas para Specs

- **Seja especifico na descricao inicial** — quanto mais contexto de inicio, melhores os requisitos
- **Revise os requisitos cuidadosamente** — e aqui que voce pega casos borda faltantes
- **Use integracao MCP** — conecte ferramentas de requisitos diretamente para importar nos specs
- **Referencie docs existentes** — use a sintaxe `#[[file:caminho]]` para apontar para specs de API ou diagramas de arquitetura

> **Fonte**: Documentacao de Specs em [kiro.dev/docs/specs/](https://kiro.dev/docs/specs/)

---

## Servidores MCP — Estendendo as Capacidades do Kiro <a name="servidores-mcp"></a>

MCP (Model Context Protocol) e um protocolo que permite ao Kiro comunicar-se com servidores externos para ferramentas e informacoes especializadas. Por exemplo, o servidor MCP de Documentacao AWS permite que o Kiro pesquise e leia docs da AWS diretamente durante uma sessao.

### Configuracao

Servidores MCP sao configurados em arquivos JSON em dois niveis:

| Escopo | Localizacao | Aplica-se A |
|--------|-------------|-------------|
| **Usuario (global)** | `~/.kiro/settings/mcp.json` | Todos os seus projetos |
| **Workspace** | `.kiro/settings/mcp.json` | Apenas o projeto atual |

A configuracao do workspace tem precedencia sobre a do usuario.

### Formato de Configuracao

```json
{
  "mcpServers": {
    "nome-do-servidor": {
      "command": "uvx",
      "args": ["nome-pacote@latest"],
      "env": {
        "VARIAVEL_ENV": "valor"
      },
      "disabled": false
    }
  }
}
```

### Instalando o `uvx`

Muitos servidores MCP usam `uvx` (do gerenciador de pacotes Python `uv`) para rodar. Instale com:

```bash
# macOS (Homebrew)
brew install uv

# pip
pip install uv

# Ou siga: https://docs.astral.sh/uv/getting-started/installation/
```

Uma vez instalado, o `uvx` baixa e roda servidores MCP automaticamente — sem instalacao por servidor necessaria.

### Servidores MCP Recomendados para Projetos AWS

#### Servidor de Documentacao AWS

Pesquise, leia e obtenha recomendacoes da documentacao AWS:

```json
{
  "mcpServers": {
    "aws-docs": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false
    }
  }
}
```

#### Servidor MCP AWS CDK

Obtenha orientacao especifica de CDK e geracao de codigo:

```json
{
  "mcpServers": {
    "aws-cdk": {
      "command": "uvx",
      "args": ["awslabs.cdk-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false
    }
  }
}
```

#### Servidor de Observabilidade CloudWatch

Monitore e analise seus recursos AWS:

```json
{
  "mcpServers": {
    "ai-observability": {
      "command": "python3",
      "args": ["/caminho/para/mcp-server/cloudwatch_mcp_server.py"],
      "env": {
        "AWS_REGION": "us-east-1"
      },
      "disabled": false
    }
  }
}
```

### Adicionando Servidores MCP pela IDE

1. Clique no icone do Kiro na barra lateral
2. Encontre "MCP Servers" no painel
3. Clique em "+" para adicionar um novo servidor
4. O Kiro guiara voce pela configuracao

### Governanca MCP Empresarial

Para organizacoes, administradores podem controlar quais servidores MCP estao disponiveis:

- **Abordagem allow-list** — Apenas servidores aprovados podem ser usados
- **Desabilitar completamente** — Bloquear todo acesso a servidores MCP
- Politicas sao aplicadas tanto no IDE quanto no CLI

> **Fonte**: Documentacao MCP em [kiro.dev/docs/mcp/](https://kiro.dev/docs/mcp/)

---

## Integracao com AWS Bedrock <a name="integracao-aws-bedrock"></a>

O Kiro e integrado nativamente com servicos AWS, incluindo o Amazon Bedrock. Esta integracao habilita fluxos de trabalho poderosos de IA que vao alem da geracao de codigo.

### O Que e o Amazon Bedrock?

O Amazon Bedrock e um servico totalmente gerenciado que fornece acesso a modelos de fundacao (como Claude, Llama, Titan) atraves de uma API unificada. Combinado com o Kiro, voce pode:

- Construir e implantar agentes de IA que usam modelos Bedrock
- Usar Bedrock AgentCore para runtime e memoria de agentes
- Implantar agentes conversacionais com memoria persistente
- Acessar multiplos modelos de fundacao do seu ambiente de desenvolvimento

### Kiro + Bedrock AgentCore

O Bedrock AgentCore fornece infraestrutura para rodar agentes de IA em producao. Com o Kiro, voce pode:

1. **Projetar agentes** usando Specs (requisitos → design → tarefas)
2. **Implementar logica do agente** com assistencia de IA do Kiro
3. **Implantar no AgentCore Runtime** para execucao em producao
4. **Adicionar memoria persistente** usando AgentCore Memory

### Implantando Agentes no Bedrock

Um fluxo tipico:

```
Kiro IDE/CLI                    AWS
┌──────────────┐               ┌──────────────────────┐
│ Sessao Spec  │               │  Bedrock AgentCore   │
│ ─────────── │               │  ┌────────────────┐  │
│ 1. Definir   │  ──deploy──> │  │ Agent Runtime   │  │
│ 2. Construir │               │  └────────────────┘  │
│ 3. Testar    │               │  ┌────────────────┐  │
│ 4. Implantar │               │  │ Agent Memory    │  │
│              │               │  └────────────────┘  │
└──────────────┘               └──────────────────────┘
```

### Pre-requisitos para Integracao com Bedrock

1. **Habilitar modelos Bedrock** na sua conta AWS via [Console Bedrock](https://console.aws.amazon.com/bedrock/)
2. **Configurar credenciais AWS** — `aws configure` com permissoes apropriadas
3. **Habilitar modelos necessarios** — selecionar quais modelos de fundacao voce precisa

### Permissoes IAM para Bedrock

Suas credenciais AWS precisam no minimo destas permissoes:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListFoundationModels",
        "bedrock:GetFoundationModel"
      ],
      "Resource": "*"
    }
  ]
}
```

Para AgentCore, adicione:

```json
{
  "Effect": "Allow",
  "Action": [
    "bedrock:CreateAgent",
    "bedrock:InvokeAgent",
    "bedrock:GetAgent",
    "bedrock:ListAgents"
  ],
  "Resource": "*"
}
```

### Steering File para Projetos Bedrock

```markdown
# Padroes de Integracao Bedrock

## Selecao de Modelo
- Usar Claude (via Bedrock) para tarefas de raciocinio complexo
- Usar Titan para embeddings e classificacao simples
- Sempre especificar versao do modelo explicitamente (sem "latest" em producao)

## Design de Agente
- Todos os agentes devem ter escopo definido e guardrails
- Usar AgentCore Memory para conversas multi-turno
- Implementar logica de fallback para throttling do modelo (respostas 429)

## Gestao de Custos
- Definir orcamentos por modelo via AWS Budgets
- Usar Provisioned Throughput para cargas de trabalho previsiveis
- Registrar todas as invocacoes no CloudWatch para atribuicao de custos
```

> **Fontes**: 
> - [Estendendo memoria conversacional no Kiro CLI usando Amazon Bedrock AgentCore Memory](https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/)
> - [Deploy rapido com Kiro no Amazon Bedrock AgentCore](https://aws.amazon.com/cn/blogs/china/kiro-quick-deploy-agent-deploy-amazon-bedrock-agentcore/)

---

## Implantando Infraestrutura AWS com o Kiro <a name="implantando-infraestrutura"></a>

O Kiro inclui um **power cloud-architect** integrado que ajuda a construir infraestrutura AWS com CDK em Python seguindo o AWS Well-Architected Framework.

### O Power Cloud-Architect

Powers sao pacotes com documentacao, guias de fluxo e servidores MCP. O power `cloud-architect` fornece:

- Informacoes de precificacao AWS
- Base de conhecimento de arquitetura AWS
- Referencias de APIs AWS
- Orientacao de boas praticas alinhada ao Well-Architected Framework

### Usando Kiro para Infraestrutura como Codigo

#### Passo 1: Configure a Estrutura do Projeto

```
meu-projeto-aws/
├── .kiro/
│   ├── steering/
│   │   └── infraestrutura.md
│   ├── hooks/
│   │   └── validar-cdk.json
│   └── settings/
│       └── mcp.json
├── infra/
│   ├── app.py
│   ├── stacks/
│   │   ├── network_stack.py
│   │   ├── compute_stack.py
│   │   └── data_stack.py
│   └── constructs/
├── src/
│   └── lambdas/
├── tests/
└── requirements.txt
```

#### Passo 2: Crie um Steering File para Infraestrutura

```markdown
# Convencoes de Infraestrutura

## Padroes CDK
- Python 3.12 com AWS CDK v2
- Um stack por contexto delimitado
- Cada construct em seu proprio arquivo, nomeado com o construct
- Interfaces de Props no mesmo arquivo do construct
- Usar constructs L2/L3 quando disponiveis; L1 apenas quando necessario

## Ambientes
- dev: `us-east-1`, capacidade minima, sem alarmes
- staging: `us-east-1`, config similar a producao, monitoramento sintetico
- prod: `us-east-1` + `eu-west-1`, capacidade total, alertas PagerDuty

## Baseline de Seguranca
- Todos os buckets S3: criptografia habilitada, acesso publico bloqueado, versionamento ativo
- Todas as funcoes Lambda: em VPC para acesso a dados, security groups restritos
- Todas as tabelas DynamoDB: criptografia em repouso, point-in-time recovery habilitado
- Roles IAM: uma role por funcao, menor privilegio, sem wildcards nos ARNs de resource
```

#### Passo 3: Peca ao Kiro para Construir a Infraestrutura

Em uma sessao Spec, descreva o que voce precisa:

> "Crie uma API serverless com API Gateway, funcoes Lambda para operacoes CRUD, DynamoDB para armazenamento e S3 para uploads de arquivo. Inclua um CDK Pipeline para deploys automatizados."

O Kiro ira:
1. Propor uma estrutura de stack CDK
2. Gerar o codigo de infraestrutura
3. Incluir roles IAM e configuracao de seguranca adequadas
4. Configurar o pipeline de deploy

#### Passo 4: Valide com Hooks

Adicione um hook que valida seu codigo CDK ao salvar:

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Validacao CDK Synth",
      "trigger": "PostFileSave",
      "matcher": "infra/.*\\.py$",
      "action": {
        "type": "command",
        "command": "cd infra && cdk synth --quiet 2>&1 | tail -5"
      }
    }
  ]
}
```

### Arquiteturas AWS Comuns com Kiro

| Arquitetura | Componentes | Abordagem Kiro |
|-------------|-------------|----------------|
| API REST | API Gateway + Lambda + DynamoDB | Sessao Spec → stack CDK |
| Event-Driven | S3 → Lambda → SQS → Lambda | Steering para padroes de evento |
| Pipeline de Dados | S3 → Lambda → Redshift | Spec com validacao de dados |
| Sistema de Auth | Cognito + API Gateway + Lambda | Spec com foco em seguranca |

### Comandos de Deploy

Apos o Kiro gerar sua infraestrutura CDK:

```bash
# Instalar dependencias
pip install -r requirements.txt

# Sintetizar template CloudFormation (valida seu codigo)
cdk synth

# Comparar mudancas contra stack implantado
cdk diff

# Implantar na sua conta AWS
cdk deploy

# Implantar stack especifico
cdk deploy MeuApp-Prod-ApiStack
```

> **Fonte**: [Boas praticas AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/best-practices.html)

---

## Governanca Empresarial e Seguranca <a name="governanca-empresarial"></a>

Para organizacoes, o Kiro fornece controles abrangentes de governanca para gerenciar desenvolvimento assistido por IA em escala.

### Politicas de Permissao

O Kiro usa um sistema de permissoes baseado em capacidades com controle granular sobre acoes do agente:

- **Bloquear comandos shell perigosos** — prevenir operacoes destrutivas
- **Negar acesso web** — restringir chamadas de rede externas
- **Forcar prompts de aprovacao** — exigir confirmacao humana para capacidades especificas
- **Restricoes de caminho de arquivo** — limitar quais arquivos o agente pode modificar

Estas politicas tem precedencia sobre configuracoes individuais dos usuarios.

### Governanca de Modelos

Administradores podem:

- **Restringir modelos disponiveis** — apenas modelos aprovados acessiveis
- **Definir modelo padrao** — aplicado automaticamente a todos os clientes
- **Rastrear uso** — relatorios de consumo por usuario e por equipe

### Governanca de Servidores MCP

Controle quais ferramentas externas sua equipe pode usar:

- **Abordagem allow-list** — crie um arquivo JSON com servidores aprovados, sirva via HTTPS, adicione a URL ao seu perfil Kiro
- **Desabilitar completamente** — bloquear todo acesso a servidores MCP em toda a organizacao
- **Aplicacao por perfil** — equipes diferentes recebem acesso a servidores diferentes

### Identidade e Acesso

O Kiro suporta provedores de identidade empresariais:

- **AWS IAM Identity Center** (SSO)
- **Microsoft Entra ID** (Azure AD)
- **Provedores SAML 2.0**

A governanca de assinatura e aplicada via condition keys IAM, permitindo:
- Restringir quais grupos podem receber assinaturas Kiro
- Impedir atribuicoes de usuarios individuais
- Usar Service Control Policies (SCPs) para aplicacao em toda a organizacao

### Arquitetura de Seguranca

O framework de seguranca do Kiro e construido sobre infraestrutura AWS:

- Dados criptografados em transito e em repouso
- Contexto de codigo processado na sua regiao AWS
- Sem treinamento no seu codigo proprietario
- Logging de auditoria disponivel via CloudTrail

### Configuracao Empresarial Recomendada

```
Nivel Organizacional
├── IAM Identity Center → SSO Kiro
├── SCP → Governanca de assinaturas
├── Perfil de Governanca
│   ├── Modelos aprovados: [Claude Sonnet, Claude Haiku]
│   ├── Allow-list MCP: [aws-docs, aws-cdk, github]
│   └── Politica de permissao: bloquear-comandos-destrutivos
│
Nivel de Equipe (workspace .kiro/)
├── steering/ → Convencoes especificas da equipe
├── hooks/ → Gates de qualidade automatizados
└── settings/mcp.json → Servidores MCP da equipe
```

> **Fonte**: Governanca empresarial em [kiro.dev/docs/enterprise/governance/](https://kiro.dev/docs/enterprise/governance/)

---

## Deploy com Um Clique — Template CloudFormation <a name="cloudformation-deployment"></a>

Este repositorio inclui um template CloudFormation validado que provisiona toda a infraestrutura AWS necessaria para o Kiro Enterprise em um unico deploy. Nenhuma criacao manual de recursos necessaria.

### O Que o Template Implanta

| Recurso | Proposito |
|---------|-----------|
| Role IAM Admin | Gerenciar perfis Kiro, assinaturas, governanca |
| Politica IAM Developer | Acesso somente leitura para desenvolvedores |
| Bucket S3 (Logs de Prompt) | Armazena prompts de usuarios e respostas do Kiro para compliance |
| Bucket S3 (Relatorios de Atividade) | Telemetria diaria de uso em CSV por usuario |
| Bucket S3 (CloudTrail) | Trilha de auditoria de todas as chamadas API do Kiro |
| Chave KMS | Criptografia gerenciada pelo cliente para todos os buckets de log |
| Trail CloudTrail | Registra quem fez o que, quando (auditoria em nivel de API) |
| Alarme CloudWatch | Alerta de orcamento para gastos com Kiro |
| Permission Boundary | Controla quais tiers de assinatura podem ser criados |

### Pre-requisitos

Antes de implantar:

1. **Conta AWS** com metodo de pagamento valido (cartao de credito obrigatorio)
2. **AWS CLI v2** instalado e configurado (`aws configure`)
3. **IAM Identity Center** habilitado na sua conta
4. **Pelo menos dois grupos** criados no Identity Center:
   - Um para Administradores Kiro
   - Um para Desenvolvedores Kiro (usuarios)
5. **Permissoes IAM** para criar stacks CloudFormation, roles IAM, buckets S3, chaves KMS

### Opcao A: Deploy Guiado (Recomendado)

O script interativo guia voce por cada parametro com validacao:

```bash
# Navegue ate a pasta cloudformation
cd cloudformation/

# Torne o script executavel
chmod +x deploy.sh

# Execute o deploy guiado
./deploy.sh
```

O script ira:
1. Validar suas credenciais AWS e a sintaxe do template
2. Solicitar cada valor de configuracao (com exemplos e validacao)
3. Mostrar uma tela de revisao antes de implantar
4. Implantar o stack CloudFormation (~3-5 minutos)
5. Verificar se todos os recursos foram criados com sucesso
6. Imprimir os proximos passos a completar no Console AWS

### Opcao B: Deploy Direto via AWS CLI

Se voce preferir uma abordagem nao-interativa:

```bash
aws cloudformation deploy \
  --template-file cloudformation/kiro-enterprise-setup.yaml \
  --stack-name minhaorg-kiro-enterprise-production \
  --region us-east-1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    OrganizationName=minhaorg \
    Environment=production \
    AwsRegion=us-east-1 \
    IdentityCenterInstanceArn=arn:aws:sso:::instance/ssoins-XXXXXXXXX \
    IdentityCenterRegion=us-east-1 \
    KiroAdminGroupId=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee \
    KiroDeveloperGroupId=ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj \
    DefaultSubscriptionTier=Pro \
    MaxSubscriptions=50 \
    EnablePromptLogging=true \
    EnableUserActivityReports=true \
    LogRetentionDays=90 \
    EnableCloudTrail=true \
    EnableKmsEncryption=true
```

### Opcao C: Console AWS (Upload do Template)

1. Abra o **CloudFormation** no Console AWS
2. Clique em **Create Stack** → **Upload a template file**
3. Faca upload do `cloudformation/kiro-enterprise-setup.yaml`
4. Preencha os parametros (organizados por categoria no console)
5. Marque a confirmacao de criacao de recursos IAM
6. Clique em **Create Stack**

### Apos o Deploy — Completar Configuracao do Kiro

O stack CloudFormation cria a infraestrutura. Complete estes passos finais no Console AWS:

```
Passo 1: Navegue ate o Console do Kiro (pesquise "Kiro" no Console AWS)
         ↓
Passo 2: Clique em "Onboard your team to Kiro"
         ↓
Passo 3: Selecione "IAM Identity Center" como fonte de identidade
         ↓
Passo 4: Crie um Perfil Kiro na regiao escolhida
         ↓
Passo 5: Va ate Users & Groups → Adicione seu grupo de desenvolvedores
         ↓
Passo 6: Atribua o tier de assinatura (Pro, Pro+, etc.)
         ↓
Passo 7: Habilite Prompt Logging → selecione o bucket S3 dos outputs do stack
         ↓
Passo 8: Habilite User Activity Reports → selecione o bucket de atividade
         ↓
Passo 9: Anote a Sign-in URL → compartilhe com os desenvolvedores
```

### Verificando o Deploy

Apos o deploy, verifique que tudo esta funcionando:

```bash
# Verificar status do stack
aws cloudformation describe-stacks \
  --stack-name minhaorg-kiro-enterprise-production \
  --region us-east-1 \
  --query "Stacks[0].StackStatus" \
  --output text

# Saida esperada: CREATE_COMPLETE

# Ver todos os outputs (nomes de buckets, ARNs de roles, etc.)
aws cloudformation describe-stacks \
  --stack-name minhaorg-kiro-enterprise-production \
  --region us-east-1 \
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
  --output table
```

### Onde os Logs Aparecerao

Uma vez que o Kiro esteja configurado e os usuarios comecem a trabalhar:

**Logs de Prompt** (prompts de usuarios + respostas do Kiro):
```
s3://minhaorg-kiro-prompt-logs-production-123456789012/
  └── AWSLogs/123456789012/KiroLogs/prompt_log/us-east-1/2026/08/20/
```

**Relatorios de Atividade do Usuario** (CSV diario por tipo de cliente):
```
s3://minhaorg-kiro-activity-reports-production-123456789012/
  └── AWSLogs/123456789012/KiroLogs/user_report/us-east-1/2026/08/20/00/
        ├── IDE_123456789012_user_report_20260820T020000Z.csv
        ├── CLI_123456789012_user_report_20260820T020000Z.csv
        └── Plugin_123456789012_user_report_20260820T020000Z.csv
```

**Auditoria CloudTrail** (chamadas de API):
```
s3://minhaorg-kiro-cloudtrail-production-123456789012/
  └── AWSLogs/123456789012/CloudTrail/us-east-1/2026/08/20/
```

### Estimativa de Custo da Infraestrutura

| Recurso | Custo Aproximado |
|---------|-----------------|
| Chave KMS | ~$1/mes + $0.03 por 10.000 requisicoes |
| Armazenamento S3 | ~$0.023/GB/mes (migra automaticamente para IA/Glacier) |
| CloudTrail | Primeira trail gratuita, $2 por 100.000 eventos |
| Alarme CloudWatch | $0.10/mes |
| **Total infraestrutura** | **~$3-10/mes** (varia por uso) |

Custos de assinatura Kiro sao separados (por usuario, por mes, baseado no tier escolhido).

### Limpeza

Para remover todos os recursos implantados:

```bash
# Esvazie os buckets S3 primeiro (obrigatorio antes da exclusao)
aws s3 rm s3://minhaorg-kiro-prompt-logs-production-123456789012 --recursive
aws s3 rm s3://minhaorg-kiro-activity-reports-production-123456789012 --recursive
aws s3 rm s3://minhaorg-kiro-cloudtrail-production-123456789012 --recursive

# Delete o stack
aws cloudformation delete-stack \
  --stack-name minhaorg-kiro-enterprise-production \
  --region us-east-1
```

> **Nota**: Buckets S3 usam `DeletionPolicy: Retain` para prevenir perda acidental de dados. Voce deve esvazia-los e deleta-los manualmente.

---

## Resumo de Boas Praticas <a name="boas-praticas"></a>

### Para Equipes Nao-Tecnicas Comecando

1. **Comece com steering files** — Escreva as convencoes do seu projeto antes de tudo. Mesmo um arquivo simples descrevendo seu tech stack e convencoes de nomenclatura faz uma diferenca enorme.

2. **Use sessoes Spec para novas features** — Nao apenas converse. O fluxo estruturado pega casos borda cedo e cria documentacao automaticamente.

3. **Configure hooks basicos** — Comece com linting ao salvar e testes apos conclusao de tarefa. Estes previnem problemas comuns sem esforco manual.

4. **Instale o servidor MCP de Documentacao AWS** — Isso da ao Kiro acesso direto a boas praticas AWS durante o desenvolvimento.

5. **Habilite o power cloud-architect** — Orientacao integrada para AWS CDK e padroes Well-Architected.

### Para Projetos de Infraestrutura AWS

1. **Um stack CDK por contexto** — Nao coloque tudo em um stack massivo
2. **Use steering para aplicar baselines de seguranca** — Menor privilegio IAM, criptografia, sem acesso publico
3. **Valide com hooks** — Execute `cdk synth` a cada salvamento em arquivos de infraestrutura
4. **Faca deploy por pipelines** — Nunca execute `cdk deploy` diretamente em producao
5. **Referencie docs de arquitetura no steering** — Use `#[[file:docs/architecture.md]]` para manter o Kiro alinhado

### Para Deploy Empresarial

1. **Configure perfis de governanca primeiro** — Restricoes de modelo, allow-lists MCP, politicas de permissao
2. **Distribua steering files via controle de versao** — Convencoes da equipe ficam no repositorio
3. **Use hooks para gates de compliance** — Scan de seguranca, verificacao de licenca, validacao de formato
4. **Integre com CI/CD existente** — O Kiro gera codigo, seu pipeline valida e implanta
5. **Audite com CloudTrail** — Rastreie todas as interacoes do Kiro com sua conta AWS

### Vitorias Rapidas com Steering Files

| Arquivo | Conteudo | Impacto |
|---------|----------|---------|
| `visao-geral-projeto.md` | Tech stack, arquitetura, decisoes-chave | Kiro entende seu projeto imediatamente |
| `padroes-codigo.md` | Estilo de linguagem, tratamento de erros, logging | Output de codigo consistente |
| `convencoes-aws.md` | Nomenclatura, IAM, regras de deploy | Infraestrutura segura por padrao |
| `padroes-proibidos.md` | O que NAO fazer (secrets hardcoded, etc.) | Previne erros comuns |

---

## Links de Referencia <a name="links-de-referencia"></a>

### Documentacao Oficial do Kiro

| Recurso | URL |
|---------|-----|
| Docs Home do Kiro | [kiro.dev/docs/](https://kiro.dev/docs/) |
| Guia de Instalacao | [kiro.dev/docs/getting-started/installation/](https://kiro.dev/docs/getting-started/installation/) |
| Primeiro Projeto | [kiro.dev/docs/getting-started/first-project/](https://kiro.dev/docs/getting-started/first-project/) |
| Steering Files | [kiro.dev/docs/steering/](https://kiro.dev/docs/steering/) |
| Hooks | [kiro.dev/docs/hooks/](https://kiro.dev/docs/hooks/) |
| Tipos de Gatilho | [kiro.dev/docs/hooks/types/](https://kiro.dev/docs/hooks/types/) |
| Exemplos de Hooks | [kiro.dev/docs/hooks/examples/](https://kiro.dev/docs/hooks/examples/) |
| Specs | [kiro.dev/docs/specs/](https://kiro.dev/docs/specs/) |
| Configuracao MCP | [kiro.dev/docs/mcp/configuration/](https://kiro.dev/docs/mcp/configuration/) |
| Exemplos MCP | [kiro.dev/docs/mcp/examples/](https://kiro.dev/docs/mcp/examples/) |
| Agentes Customizados | [kiro.dev/docs/custom-agents/](https://kiro.dev/docs/custom-agents/) |
| Permissoes | [kiro.dev/docs/permissions/](https://kiro.dev/docs/permissions/) |
| Governanca Empresarial | [kiro.dev/docs/enterprise/governance/](https://kiro.dev/docs/enterprise/governance/) |
| Privacidade e Seguranca | [kiro.dev/docs/privacy-and-security/](https://kiro.dev/docs/privacy-and-security/) |
| Escopos de Configuracao | [kiro.dev/docs/configuration/](https://kiro.dev/docs/configuration/) |
| Powers | [kiro.dev/docs/powers/installation/](https://kiro.dev/docs/powers/installation/) |
| Onboarding Empresarial | [kiro.dev/docs/enterprise/getting-started/](https://kiro.dev/docs/enterprise/getting-started/) |
| Inscrever Sua Equipe | [kiro.dev/docs/enterprise/subscribe/](https://kiro.dev/docs/enterprise/subscribe/) |
| Cobranca e Precos | [kiro.dev/docs/enterprise/billing/](https://kiro.dev/docs/enterprise/billing/) |
| Gestao de Assinaturas | [kiro.dev/docs/enterprise/subscription-management/](https://kiro.dev/docs/enterprise/subscription-management/) |
| Permissoes IAM para Kiro | [kiro.dev/docs/enterprise/iam/](https://kiro.dev/docs/enterprise/iam/) |
| Pagina de Precos | [kiro.dev/pricing/](https://kiro.dev/pricing/) |

### Recursos de Integracao AWS

| Recurso | URL |
|---------|-----|
| Boas Praticas AWS CDK | [docs.aws.amazon.com/cdk/latest/guide/best-practices.html](https://docs.aws.amazon.com/cdk/latest/guide/best-practices.html) |
| Kiro + Bedrock AgentCore Memory | [Blog AWS](https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/) |
| Kiro + Agent Toolkit para AWS | [artigo repost.aws](https://www.repost.aws/articles/AReLJ1UhxdTzqXP-h421MFCg/use-kiro-ide-with-agent-toolkit-for-aws-to-build-deploy-and-manage-your-aws-environment) |
| Transformar DevOps com Kiro | [Blog AWS Setor Publico](https://aws.amazon.com/blogs/publicsector/transform-devops-practice-with-kiro-ai-powered-agents/) |
| Blog Steering Kiro | [kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/](https://kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/) |
| Blog Steering Global | [kiro.dev/blog/stop-repeating-yourself/](https://kiro.dev/blog/stop-repeating-yourself/) |

---

> **Nota**: O conteudo deste guia foi reformulado para conformidade com restricoes de licenciamento. Todas as informacoes sao provenientes da documentacao oficial do Kiro e recursos AWS linkados acima.

---

*Ultima atualizacao: Agosto 2026*

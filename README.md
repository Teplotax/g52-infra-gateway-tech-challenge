# g52-infra-gateway-tech-challenge

Infraestrutura Terraform para provisionamento de um **API Gateway REST** regional na AWS, com suporte opcional a API Key, throttling e quota. Projeto do Grupo 52 para o Tech Challenge.

## Recursos provisionados

| Recurso | Descrição |
|---|---|
| `aws_api_gateway_rest_api` | REST API regional |
| `aws_api_gateway_api_key` | API Key (criada apenas se `require_api_key = true`) |
| `aws_api_gateway_usage_plan` | Plano de uso com throttling e quota mensal |
| `aws_api_gateway_usage_plan_key` | Associação da API Key ao Usage Plan |

## Estrutura

```
infra/
├── main.tf                        # Recursos principais (API Gateway, API Key, Usage Plan)
├── variables.tf                   # Declaração de variáveis
├── locals.tf                      # Locals e tags
├── providers.tf                   # Provider AWS + backend S3
├── outpouts.tf                    # Outputs: api_gateway_id e api_key
└── inventories/
    └── dev/
        └── terraform.tfvars       # Variáveis do ambiente dev
```

## Pré-requisitos

- Terraform >= 1.6
- AWS CLI configurado com permissões adequadas
- Bucket S3 para armazenar o estado remoto (`teplotax-terraform-state-dev`)


## Variáveis principais

| Variável | Tipo | Descrição |
|---|---|---|
| `api_name` | string | Nome da REST API |
| `environment` | string | Nome do ambiente (ex: `dev`) |
| `vpc_id` | string | ID da VPC |
| `require_api_key` | bool | Habilita criação de API Key e Usage Plan (default: `false`) |
| `throttle_burst_limit` | number | Limite de burst de requisições (default: `500`) |
| `throttle_rate_limit` | number | Limite de taxa de requisições por segundo (default: `100`) |
| `quota_limit` | number | Quota mensal de requisições (default: `1000000`) |
| `log_retention_days` | number | Retenção de logs em dias (default: `1`) |
| `aws_region` | string | Região AWS (default: `sa-east-1`) |
| `destroy` | bool | Se `true`, o pipeline executa `terraform destroy` |

## Outputs

| Output | Descrição |
|---|---|
| `api_gateway_id` | ID da REST API criada |
| `api_key` | Valor da API Key gerada (sensível; vazio se `require_api_key = false`) |

## Pipeline CI/CD

O projeto usa três workflows GitHub Actions com promoção automática entre ambientes:

```
feature/** → develop → release/vX.X.X → main
```

| Workflow | Gatilho | Ação |
|---|---|---|
| `1-feature-to-dev-pr.yml` | Push em `feature/**` | Abre PR automático para `develop` |
| `2-terraform-dev.yml` | Push/PR em `develop` | Executa `terraform plan` (PR) ou `apply/destroy` (push); cria branch e PR `release/vX.X.X` |
| `4-release-to-main.yml` | PR fechado em `release/**` | Abre PR automático da release para `main` |

A autenticação com a AWS é feita via **OIDC** (sem chaves estáticas). O nome do estado remoto é extraído automaticamente do `api_name` no `terraform.tfvars`.
# portfolio-iac

Infrastructure as Code para o projeto Portfolio, gerenciado via [Terraform Cloud](https://app.terraform.io/app/portfolio-helioalb/workspaces/portfolio-iac).

## TL;DR

```bash
# 1. Configure credenciais AWS no Terraform Cloud workspace
# 2. Clone e inicialize
terraform login
terraform init

# 3. (Opcional) Crie terraform.tfvars com suas customizações
# 4. Deploy
terraform plan
terraform apply

# Outputs: instance_id, instance_public_ip, etc.
```

## Recursos

- **VPC** — VPC dedicada (10.0.0.0/25, 128 IPs) com DNS support e DNS hostnames habilitados.
- **Subnet pública** — Subnet (10.0.0.0/26, 64 IPs) com rota para Internet Gateway.
- **Subnet privada** — Subnet isolada (10.0.0.64/26, 64 IPs) sem acesso direto à internet.
- **Internet Gateway** — Acesso à internet para a subnet pública.
- **EC2 Instance** — Amazon Linux 2023, com IMDSv2, volume EBS criptografado e monitoramento detalhado habilitado.
- **Docker** — Docker e Docker Compose instalados automaticamente via user data script.
- **Security Group** — Regras de ingress configuráveis para HTTP, HTTPS e SSH, com egress aberto.

## Estrutura do projeto

| Arquivo | Descrição |
|---|---|
| `versions.tf` | Terraform Cloud backend, versão do Terraform e providers |
| `providers.tf` | Configuração do provider AWS com `default_tags` e `allowed_account_ids` |
| `variables.tf` | Declaração de variáveis |
| `main.tf` | VPC, subnets (pública e privada), internet gateway, route tables, security group e instância EC2 |
| `outputs.tf` | Outputs da infraestrutura |
| `user_data.sh` | Script de inicialização para instalar Docker e Docker Compose |
| `example.tfvars` | Exemplo de valores para variáveis |
| `.terraform.lock.hcl` | Lock file para versões de providers (versionado) |

**Arquivos versionados:**
- Todos os `.tf`, `.sh`, `.md`
- `.terraform.lock.hcl` (garante versões consistentes de providers)

**Arquivos ignorados (.gitignore):**
- `.terraform/` (dependências locais)
- `*.tfstate*` (state nunca deve ser versionado com backend remoto)
- `*.tfvars` (podem conter dados sensíveis)

## Pré-requisitos

- Terraform >= 1.6
- AWS Provider `~> 6.33.0`
- Conta na [Terraform Cloud](https://app.terraform.io) (org: `portfolio-helioalb`)
- Credenciais AWS configuradas no workspace do Terraform Cloud (conta `427261938086`)

### Configurar credenciais AWS no Terraform Cloud

**Opção 1: OIDC (recomendada)**

1. Criar OIDC Provider na AWS IAM com URL `https://app.terraform.io` e audience `aws.workload.identity`
2. Criar IAM Role com trust policy para o workspace
3. No Terraform Cloud workspace, adicionar variáveis de ambiente:
   - `TFC_AWS_PROVIDER_AUTH = true`
   - `TFC_AWS_RUN_ROLE_ARN = arn:aws:iam::427261938086:role/<NOME_DA_ROLE>`

**Opção 2: Chaves estáticas**

No workspace, adicionar variáveis de ambiente (marcar `AWS_SECRET_ACCESS_KEY` como sensitive):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Uso

```bash
# Login no Terraform Cloud
terraform login

# Inicializar
terraform init

# Planejar
terraform plan

# Aplicar
terraform apply
```

## Variáveis

| Variável | Descrição | Default |
|---|---|---|
| `TFC_AWS_PROVIDER_AUTH` | Autenticação OIDC do Terraform Cloud com AWS | `true` |
| `project_name` | Nome do projeto | `portfolio` |
| `environment` | Ambiente (dev, staging, prod) | `prod` |
| `aws_region` | Região AWS | `us-east-1` |
| `vpc_cidr` | CIDR block da VPC | `10.0.0.0/25` |
| `public_subnet_cidr` | CIDR block da subnet pública | `10.0.0.0/26` |
| `private_subnet_cidr` | CIDR block da subnet privada | `10.0.0.64/26` |
| `instance_type` | Tipo da instância EC2 | `t3.micro` |
| `ami_id` | AMI customizada (vazio = Amazon Linux 2023) | `""` |
| `key_pair_name` | Key pair para SSH | `""` |
| `root_volume_size` | Tamanho do volume root (GB) | `20` |
| `root_volume_type` | Tipo do volume root | `gp3` |
| `associate_public_ip` | Associar IP público | `true` |
| `allowed_ssh_cidrs` | CIDRs permitidos para SSH | `[]` |
| `allowed_http_cidrs` | CIDRs permitidos para HTTP | `["0.0.0.0/0"]` |
| `allowed_https_cidrs` | CIDRs permitidos para HTTPS | `["0.0.0.0/0"]` |
| `enable_docker` | Instalar Docker na instância | `true` |

## Arquitetura de Rede

A VPC é dividida em duas subnets em `/26` (64 IPs cada):

- **Subnet pública (`10.0.0.0/26`)** — Contém a instância EC2 com IP público, acesso via Internet Gateway
- **Subnet privada (`10.0.0.64/26`)** — Isolada da internet, pode ser usada para bancos de dados ou recursos internos

A instância EC2 é criada na subnet **pública** por padrão.

## Docker

Se `enable_docker = true` (padrão), Docker e Docker Compose são instalados automaticamente na instância via `user_data.sh`.

### Conexão SSH

```bash
ssh -i /path/to/key.pem ec2-user@<instance_public_ip>
```

### Verificar Docker

```bash
docker --version
docker compose version  # Plugin oficial (sem hífen)
docker ps
```

**Nota:** O projeto usa `docker-compose-plugin` (comando: `docker compose`), não o binário standalone `docker-compose`.

O usuário `ec2-user` é adicionado ao grupo `docker` automaticamente, permitindo usar Docker sem `sudo`.

## Outputs

Após o `terraform apply`, os seguintes outputs são exibidos:

| Output | Descrição |
|---|---|
| `instance_id` | ID da instância EC2 |
| `instance_public_ip` | IP público da instância |
| `instance_private_ip` | IP privado da instância |
| `instance_public_dns` | DNS público da instância |
| `security_group_id` | ID do security group |
| `vpc_id` | ID da VPC |
| `subnet_id` | ID da subnet pública |
| `private_subnet_id` | ID da subnet privada |
| `ami_id` | ID da AMI utilizada |

## Custo Estimado

**~$8.59/mês** (baseado em `t3.micro` na `us-east-1` com uso 24/7)

- EC2 t3.micro: ~$7.60/mês
- EBS gp3 20GB: ~$1.60/mês
- Transferência de dados: variável

**Recursos gratuitos (primeiro ano AWS):** 750 horas/mês de t3.micro são gratuitas no Free Tier.

## Configuração Adicional

### Criar Key Pair para SSH

```bash
# Gerar chave localmente
ssh-keygen -t rsa -b 4096 -f ~/.ssh/portfolio-key

# Importar para AWS (via CLI ou Console)
aws ec2 import-key-pair --key-name portfolio-key \
  --public-key-material fileb://~/.ssh/portfolio-key.pub \
  --region us-east-1

# Definir variável no terraform.tfvars ou Terraform Cloud
# key_pair_name = "portfolio-key"
```

### Personalizar variáveis

Crie um arquivo `terraform.tfvars` (não versionado):

```hcl
project_name         = "portfolio"
environment          = "prod"
instance_type        = "t3.small"
allowed_ssh_cidrs    = ["203.0.113.0/24"]  # Seu IP
enable_docker        = true
```

## Segurança

O projeto implementa as seguintes práticas de segurança:

- ✅ **IMDSv2 obrigatório** — Proteção contra SSRF
- ✅ **Volume EBS criptografado** — Dados em repouso protegidos
- ✅ **SSH desabilitado por padrão** — `allowed_ssh_cidrs = []`
- ✅ **Security Group com regras explícitas** — Princípio do menor privilégio
- ✅ **Default tags** — Rastreabilidade de recursos
- ✅ **Account ID validado** — Previne deploy em conta errada
- ✅ **Subnet privada isolada** — Sem acesso direto à internet

**Recomendações:**

- Use OIDC em vez de chaves estáticas no Terraform Cloud
- Restrinja `allowed_ssh_cidrs` ao seu IP específico
- Habilite AWS GuardDuty e Security Hub para monitoramento
- Configure AWS Backup para a instância EC2

## Troubleshooting

### Erro: "No valid credential sources found"

**Causa:** Credenciais AWS não configuradas no Terraform Cloud.

**Solução:** Configure OIDC ou adicione `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` como variáveis de ambiente no workspace.

### Erro: "no matching EC2 VPC found"

**Causa:** Tentando usar VPC default que não existe.

**Solução:** O código atual cria VPC própria, não depende de VPC default.

### Não consigo acessar via SSH

**Causa:** `allowed_ssh_cidrs` vazio ou Security Group sem regra SSH.

**Solução:**
```hcl
allowed_ssh_cidrs = ["SEU.IP.PUBLICO.AQUI/32"]
```

### Docker não está instalado após apply

**Causa:** User data demora 2-3 minutos para executar.

**Solução:** Aguarde alguns minutos e verifique os logs:
```bash
ssh ec2-user@<instance_ip>
sudo tail -f /var/log/cloud-init-output.log
```

## Licença

Este projeto é de código aberto para fins educacionais.


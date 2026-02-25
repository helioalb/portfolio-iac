# portfolio-iac

Infrastructure as Code para o projeto Portfolio, gerenciado via [Terraform Cloud](https://app.terraform.io/app/portfolio-helioalb/workspaces/portfolio-iac).

## Recursos

- **VPC** — VPC dedicada com DNS support e DNS hostnames habilitados.
- **Subnet pública** — Subnet com rota para Internet Gateway.
- **Internet Gateway** — Acesso à internet para a subnet pública.
- **EC2 Instance** — Amazon Linux 2023, com IMDSv2, volume EBS criptografado e monitoramento detalhado habilitado.
- **Security Group** — Regras de ingress configuráveis para HTTP, HTTPS e SSH, com egress aberto.

## Estrutura do projeto

| Arquivo | Descrição |
|---|---|
| `versions.tf` | Terraform Cloud backend, versão do Terraform e providers |
| `providers.tf` | Configuração do provider AWS com `default_tags` e `allowed_account_ids` |
| `variables.tf` | Declaração de variáveis |
| `main.tf` | VPC, subnet, internet gateway, security group e instância EC2 |
| `outputs.tf` | Outputs da infraestrutura |
| `example.tfvars` | Exemplo de valores para variáveis |

## Pré-requisitos

- Terraform >= 1.6
- Conta na [Terraform Cloud](https://app.terraform.io) (org: `portfolio-helioalb`)
- Credenciais AWS configuradas no workspace do Terraform Cloud (conta `427261938086`)

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
| `vpc_cidr` | CIDR block da VPC | `10.0.0.0/16` |
| `subnet_cidr` | CIDR block da subnet pública | `10.0.1.0/24` |
| `instance_type` | Tipo da instância EC2 | `t3.micro` |
| `ami_id` | AMI customizada (vazio = Amazon Linux 2023) | `""` |
| `key_pair_name` | Key pair para SSH | `""` |
| `root_volume_size` | Tamanho do volume root (GB) | `20` |
| `root_volume_type` | Tipo do volume root | `gp3` |
| `associate_public_ip` | Associar IP público | `true` |
| `allowed_ssh_cidrs` | CIDRs permitidos para SSH | `[]` |
| `allowed_http_cidrs` | CIDRs permitidos para HTTP | `["0.0.0.0/0"]` |
| `allowed_https_cidrs` | CIDRs permitidos para HTTPS | `["0.0.0.0/0"]` |

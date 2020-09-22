# AWS Elastic Container Service (ECS) Terraform

Ajustar as variáveis no arquivo dev.tfvars ou criar um novo arquivo com as respectivas variáveis

## Como executar

```bash
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -auto-approve -var-file="dev.tfvars"
```

Verificar o ip que será exibido no ouput e acessar pelo navegador

## Versão do terraform utilizado
```
Terraform v0.13.2
+ provider registry.terraform.io/hashicorp/aws v3.7.0
+ provider registry.terraform.io/hashicorp/http v1.2.0
+ provider registry.terraform.io/hashicorp/template v2.1.2

Your version of Terraform is out of date! The latest version
is 0.13.3. You can update by downloading from https://www.terraform.io/downloads.html
```
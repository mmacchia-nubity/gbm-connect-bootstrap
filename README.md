# GBM Connect Bootstrap - Guía de Despliegue

## Resumen
Este repositorio contiene la infraestructura bootstrap para el proyecto GBM Connect, incluyendo buckets S3 y pipelines CI/CD para ambientes staging y production.

## Prerrequisitos

### 1. Roles IAM Requeridos

- **gbm-connect-bootstrap-oidc-role**: Permite a GitHub Actions ejecutar el bootstrap via OIDC
- **gbm-connect-pipeline-stg-role**: Rol para CodePipeline en ambiente staging
- **gbm-connect-build-stg-role**: Rol para CodeBuild en ambiente staging
- **gbm-connect-release-role**: Rol para crear releases desde staging
- **gbm-connect-pipeline-prd-role**: Rol para CodePipeline en ambiente production
- **gbm-connect-build-prd-role**: Rol para CodeBuild en ambiente production

### 2. Parámetros SSM Requeridos

#### Para Staging (STG)
```bash
aws ssm put-parameter --name "/gbm/stg/artifact-bucket" \
  --value "gbm-connect-artifacts-stg" --type String

aws ssm put-parameter --name "/gbm/stg/pipeline-role" \
  --value "arn:aws:iam::{AWS_ACCOUNT_ID}:role/gbm-connect-pipeline-stg-role" --type String

aws ssm put-parameter --name "/gbm/stg/build-role" \
  --value "arn:aws:iam::{AWS_ACCOUNT_ID}:role/gbm-connect-build-stg-role" --type String

aws ssm put-parameter --name "/gbm/stg/release-role" \
  --value "arn:aws:iam::{AWS_ACCOUNT_ID}:role/gbm-connect-release-role" --type String
```

#### Para Production (PRD)
```bash
aws ssm put-parameter --name "/gbm/prd/artifact-bucket" \
  --value "gbm-connect-artifacts-prd" --type String

aws ssm put-parameter --name "/gbm/prd/pipeline-role" \
  --value "arn:aws:iam::{AWS_ACCOUNT_ID}:role/gbm-connect-pipeline-prd-role" --type String

aws ssm put-parameter --name "/gbm/prd/build-role" \
  --value "arn:aws:iam::{AWS_ACCOUNT_ID}:role/gbm-connect-build-prd-role" --type String
```

### 3. Secrets Manager

Crear el token de GitHub en Secrets Manager:
```bash
aws secretsmanager create-secret --name "github/token" \
  --description "GitHub Personal Access Token" \
  --secret-string '{"token":"{GITHUB_TOKEN}"}'
```

### 4. Configuración GitHub

#### Environments
1. Ir a Settings > Environments en el repositorio
2. Crear environment `production` con protección manual

#### OIDC Provider (si no existe)
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list {OIDC_THUMBPRINT} \
  --client-id-list sts.amazonaws.com
```

## Proceso de Despliegue

### Opción 1: GitHub Actions (Recomendado)

1. **Push a main**: Despliega automáticamente STG y luego PRD (con aprobación manual)
2. **Workflow manual**: Ir a Actions > Bootstrap Pipelines > Run workflow

### Opción 2: Despliegue Local

```bash
# Validar templates
./scripts/validate.sh

# Desplegar STG
./scripts/bootstrap.sh stg

# Desplegar PRD
./scripts/bootstrap.sh prd
```

## Recursos Creados

### Buckets S3
- `gbm-connect-artifacts-stg-{AWS_REGION}` - Artifacts STG
- `gbm-connect-artifacts-prd-{AWS_REGION}` - Artifacts PRD
- `gbm-connect-audio-{AWS_REGION}-stg` - Audio prompts STG
- `gbm-connect-audio-{AWS_REGION}-prd` - Audio prompts PRD

### Pipelines
- `gbm-connect-pipeline-stg` - Pipeline staging
- `gbm-connect-pipeline-prd` - Pipeline production

### CodeBuild Projects
- `gbm-connect-codebuild-stg` - Build STG
- `gbm-connect-codebuild-prd` - Build PRD
- `gbm-connect-release-stg` - Release STG

## Flujo de Buckets

El template `buckets.yaml` crea los buckets S3 y exporta sus nombres. Los pipelines los referencian de dos formas:

1. **Via SSM**: Los nombres se almacenan en parámetros SSM y se leen en el workflow
2. **Via CloudFormation Exports**: Los templates pueden referenciar directamente los outputs exportados

**Opción recomendada**: Usar SSM para mayor flexibilidad y control de configuración por ambiente.

## Troubleshooting

### Error: Role no existe
Verificar que todos los roles IAM estén creados correctamente:
```bash
aws iam get-role --role-name gbm-connect-pipeline-stg-role
```

### Error: Parámetro SSM no encontrado
Verificar que los parámetros SSM estén configurados:
```bash
aws ssm get-parameter --name "/gbm/stg/artifact-bucket"
```

### Error: GitHub token inválido
Verificar el secret en Secrets Manager:
```bash
aws secretsmanager get-secret-value --secret-id "github/token"
```

## Estructura del Proyecto

```
pser-gbm-bootstrap/
├── .github/workflows/
│   └── bootstrap.yml          # GitHub Actions workflow
├── scripts/
│   ├── bootstrap.sh           # Script de despliegue local
│   └── validate.sh           # Validación de templates
├── templates/
│   ├── buckets.yaml          # S3 buckets
│   ├── pipelines-stg.yaml    # Pipeline staging
│   └── pipelines-prd.yaml    # Pipeline production
└── READMEs.md               # Esta documentación
```

## Próximos Pasos

1. Ejecutar el bootstrap para crear la infraestructura base
2. Configurar el repositorio principal del proyecto
3. Verificar que los pipelines se ejecuten correctamente
4. Configurar notificaciones y monitoreo adicional
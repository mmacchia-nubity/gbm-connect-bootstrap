# GBM Connect - Bootstrap Pipelines

Este repositorio contiene la infraestructura **bootstrap** para los pipelines de CI/CD de GBM Connect.

## Contenido
- `bootstrap.yaml`: crea los buckets y los pipelines de STG y PRD.
- `samconfig.toml`: define parámetros de despliegue por ambiente.
- `.github/workflows/deploy-stg.yml`: despliegue automático en STG.
- `.github/workflows/deploy-prd.yml`: despliegue automático en PRD.

## Roles requeridos (los provee el cliente)
**Por ambiente:**
- `gbm-connect-pipeline-{env}-role`
- `gbm-connect-build-{env}-role`
- `gbm-connect-bootstrap-role` (para despliegue del bootstrap)

**Solo STG:**
- `gbm-connect-release-role`

## Recursos creados por ambiente
**Bucket:** `gbm-connect-artifacts-{env}`
**Pipeline:** `gbm-connect-pipeline-{env}`
**Build Project:** `gbm-connect-build-{env}`
**Release Project:** `gbm-connect-release` (solo STG)

## Flujo de despliegue
1. Push a `master` en GitHub → dispara el pipeline STG.
2. Pipeline STG ejecuta `buildspec-stage.yml`.
   - Si pasa todo, requiere **Manual Approval**.
   - Si se aprueba, crea un **release/tag** en GitHub con `buildspec-create-tag.yml`.
3. El release/tag en GitHub dispara automáticamente el pipeline PRD.
4. Pipeline PRD ejecuta `buildspec-prod.yml`.

## Prerrequisitos
- AWS CLI configurado
- SAM CLI instalado
- Token de GitHub almacenado en AWS Secrets Manager con el nombre `github/token`

## Cómo desplegar manualmente
```bash
# STG
sam build
sam deploy --config-env stg

# PRD (en cuenta separada)
sam build
sam deploy --config-env prd
```

## Cómo desplegar con GitHub Actions
1. Ir a **Actions** en GitHub.
2. Ejecutar manualmente **Deploy Bootstrap STG** o **Deploy Bootstrap PRD**.

## Configuración del token de GitHub
El token de GitHub debe estar almacenado en AWS Secrets Manager:
```bash
aws secretsmanager create-secret \
  --name github/token \
  --description "GitHub OAuth token for CodePipeline" \
  --secret-string '{"token":"ghp_your_token_here"}'
```

## Estructura del repositorio
```
bootstrap/
├── bootstrap.yaml          # Template CloudFormation
├── samconfig.toml          # Configuración SAM
├── README.md              # Esta documentación
└── .github/
    └── workflows/
        ├── deploy-stg.yml # Workflow STG
        └── deploy-prd.yml # Workflow PRD
```

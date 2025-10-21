# 🔧 Guía de Personalización - GBM Bootstrap

Esta guía explica qué valores debe modificar otro equipo para adaptar este repositorio a su proyecto.

## 📋 Valores a Modificar

### 1. GitHub Workflow (`.github/workflows/bootstrap.yml`)

```yaml
env:
  AWS_REGION: us-east-1                    # ← CAMBIAR: Región AWS deseada
  AWS_ACCOUNT_ID_STG: "xxxxxxx"       # ← CAMBIAR: Account ID de staging
  AWS_ACCOUNT_ID_PRD: "xxxxxxx"       # ← CAMBIAR: Account ID de production

# En deploy-stg y deploy-prd:
GitHubOwner=mmacchia-nubity                # ← CAMBIAR: Owner del repo principal
GitHubRepo=pser-gbm-sfdc-integration       # ← CAMBIAR: Nombre del repo principal
```

### 2. Pipeline STG (`templates/pipelines-stg.yaml`)

```yaml
Parameters:
  GitHubOwner:
    Default: "mmacchia-nubity"             # ← CAMBIAR: Owner del repo principal

  GitHubRepo:
    Default: "pser-gbm-sfdc-integration"   # ← CAMBIAR: Nombre del repo principal

# En el pipeline:
Branch: pser-29-deploy-test                # ← CAMBIAR: Rama principal (ej: main)
```

### 3. Buckets S3 (`templates/buckets.yaml`)

```yaml
Resources:
  ArtifactBucket:
    Properties:
      BucketName: !Sub "gbm-connect-artifacts-${Environment}-${AWS::Region}"  # ← CAMBIAR: Prefijo del bucket

  AudioBucket:
    Properties:
      BucketName: !Sub "gbm-connect-audio-useast2-${Environment}"            # ← CAMBIAR: Nombre y región
```

### 4. Nombres de Recursos

**Stack Names (en workflow):**
```bash
--stack-name gbm-connect-buckets-stg       # ← CAMBIAR: Prefijo del proyecto
--stack-name gbm-connect-pipeline-stg      # ← CAMBIAR: Prefijo del proyecto
```

**CodeBuild Projects:**
```yaml
Name: gbm-connect-codebuild-stg            # ← CAMBIAR: Prefijo del proyecto
Name: gbm-connect-release-stg              # ← CAMBIAR: Prefijo del proyecto
```

**Pipeline Names:**
```yaml
Name: gbm-connect-pipeline-stg             # ← CAMBIAR: Prefijo del proyecto
```

### 5. Roles IAM

**En workflow y templates, cambiar prefijos:**
```bash
role/gbm-connect-bootstrap-oidc-role       # ← CAMBIAR: Prefijo del proyecto
```

### 6. Parámetros SSM

**Cambiar el prefijo `/gbm/` por el de su proyecto:**
```bash
/gbm/stg/artifact-bucket                   # ← CAMBIAR: /mi-proyecto/stg/artifact-bucket
/gbm/stg/pipeline-role                     # ← CAMBIAR: /mi-proyecto/stg/pipeline-role
/gbm/stg/build-role                        # ← CAMBIAR: /mi-proyecto/stg/build-role
/gbm/stg/release-role                      # ← CAMBIAR: /mi-proyecto/stg/release-role
```

### 7. BuildSpec Files

**En pipelines, cambiar referencias:**
```yaml
BuildSpec: buildspec-stg.yml               # ← VERIFICAR: Que exista en el repo principal
BuildSpec: buildspec-release.yml           # ← VERIFICAR: Que exista en el repo principal
BuildSpec: buildspec-prd.yml               # ← VERIFICAR: Que exista en el repo principal
```

## 🔄 Proceso de Personalización

### Paso 1: Definir Nombres
```bash
PROYECTO="mi-proyecto"                     # Nombre de su proyecto
GITHUB_ORG="mi-organizacion"               # Su organización GitHub
REPO_PRINCIPAL="mi-repo-principal"         # Repo que será desplegado
AWS_REGION="us-east-1"                     # Su región preferida
```

### Paso 2: Buscar y Reemplazar
Usar find/replace en todo el repositorio:

```bash
# Nombres de proyecto
gbm-connect → mi-proyecto

# GitHub
mmacchia-nubity → mi-organizacion
pser-gbm-sfdc-integration → mi-repo-principal

# Región (si es diferente)
us-east-1 → us-east-1
useast1 → useast1

# Account IDs
xxxxxxx → SU_ACCOUNT_ID_STG
xxxxxxx → SU_ACCOUNT_ID_PRD

# Ramas
pser-29-deploy-test → main
```

### Paso 3: Actualizar SSM Parameters
```bash
# Cambiar prefijo /gbm/ por /mi-proyecto/
/gbm/stg/ → /mi-proyecto/stg/
/gbm/prd/ → /mi-proyecto/prd/
```

### Paso 4: Verificar BuildSpecs
Asegurar que el repo principal tenga:
- `buildspec-stg.yml`
- `buildspec-prd.yml`
- `buildspec-release.yml`

## ⚠️ Consideraciones Importantes

1. **Buckets S3**: Los nombres deben ser únicos globalmente
2. **Roles IAM**: Crear antes de ejecutar el bootstrap
3. **OIDC Provider**: Configurar en AWS antes del primer deploy
4. **GitHub Secrets**: Configurar `github/token` en Secrets Manager
5. **Environments**: Crear `production` environment en GitHub con protección manual

## 📁 Archivos a Modificar

```
├── .github/workflows/bootstrap.yml        # ← Account IDs, región, repos GitHub
├── templates/buckets.yaml                 # ← Nombres de buckets
├── templates/pipelines-stg.yaml           # ← GitHub owner/repo, ramas
├── templates/pipelines-prd.yaml           # ← GitHub owner/repo, ramas
└── scripts/bootstrap.sh                   # ← Stack names, roles (si existe)
```

## 🎯 Checklist Final

- [ ] Cambiar todos los `gbm-connect` por su prefijo
- [ ] Actualizar `mmacchia-nubity` por su GitHub org
- [ ] Cambiar `pser-gbm-sfdc-integration` por su repo
- [ ] Verificar Account IDs en workflow
- [ ] Actualizar región si es necesario
- [ ] Cambiar ramas de `pser-29-deploy-test` a `main`
- [ ] Crear roles IAM con los nuevos nombres
- [ ] Actualizar parámetros SSM con nuevo prefijo
- [ ] Verificar que buildspecs existan en repo principal
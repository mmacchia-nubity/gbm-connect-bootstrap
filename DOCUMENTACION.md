# 📖 Documentación - Bootstrap Pipelines GBM Connect

Este documento describe los pasos necesarios para desplegar la infraestructura de **pipelines** (STG y PRD) utilizando **GitHub Actions**, **CloudFormation** y **OIDC**.

---

## 🔹 1. Requisitos previos

1. **Cuenta AWS** con permisos de administrador para crear roles IAM, buckets y pipelines.
2. **Repositorio GitHub** con workflows configurados en `.github/workflows/bootstrap.yml`.
3. **OIDC Provider** configurado en IAM:
   - `arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com`.

---

## 🔹 2. Creación manual de Roles IAM

Los roles de ejecución de **CodePipeline** y **CodeBuild** **NO** se crean automáticamente.
Debes crearlos manualmente con las siguientes trust & permission policies.

### 2.1 Rol OIDC para GitHub Actions
Nombre sugerido: `gbm-connect-bootstrap-oidc-role`

**Trust policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:mmacchia-nubity/gbm-connect-bootstrap:ref:refs/heads/*",
            "repo:mmacchia-nubity/gbm-connect-bootstrap:environment:*"
          ]
        }
      }
    }
  ]
}
Permissions policy (ejemplo mínimo):

json
Copy code
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "cloudformation:*", "Resource": "*" },
    { "Effect": "Allow", "Action": "s3:*", "Resource": "*" },
    { "Effect": "Allow", "Action": "iam:PassRole", "Resource": "*" },
    { "Effect": "Allow", "Action": "ssm:GetParameter", "Resource": "*" }
  ]
}
2.2 Roles STG
gbm-connect-pipeline-stg-role → lo asume CodePipeline.

gbm-connect-build-stg-role → lo asume CodeBuild.

gbm-connect-release-role → lo asume CodeBuild para crear tags en GitHub.

2.3 Roles PRD
gbm-connect-pipeline-prd-role → lo asume CodePipeline.

gbm-connect-build-prd-role → lo asume CodeBuild.

🔹 3. Parámetros en AWS Systems Manager (SSM)
Para no hardcodear recursos en el repositorio, los ARNs y nombres de buckets se guardan en SSM Parameter Store.

Ejecutar los siguientes comandos (ajustar <ACCOUNT_ID>):

3.1 STG
bash
Copy code
aws ssm put-parameter --name /gbm/stg/artifact-bucket --type String --value gbm-connect-artifacts-stg
aws ssm put-parameter --name /gbm/stg/pipeline-role --type String --value arn:aws:iam::<ACCOUNT_ID>:role/gbm-connect-pipeline-stg-role
aws ssm put-parameter --name /gbm/stg/build-role --type String --value arn:aws:iam::<ACCOUNT_ID>:role/gbm-connect-build-stg-role
aws ssm put-parameter --name /gbm/stg/release-role --type String --value arn:aws:iam::<ACCOUNT_ID>:role/gbm-connect-release-role
3.2 PRD
bash
Copy code
aws ssm put-parameter --name /gbm/prd/artifact-bucket --type String --value gbm-connect-artifacts-prd
aws ssm put-parameter --name /gbm/prd/pipeline-role --type String --value arn:aws:iam::<ACCOUNT_ID>:role/gbm-connect-pipeline-prd-role
aws ssm put-parameter --name /gbm/prd/build-role --type String --value arn:aws:iam::<ACCOUNT_ID>:role/gbm-connect-build-prd-role
🔹 4. Flujo de despliegue
Hacer push a main en el repo.

GitHub Actions ejecuta .github/workflows/bootstrap.yml:

validate → lint de templates.

deploy-stg → crea bucket y pipeline de STG.

deploy-prd → crea bucket y pipeline de PRD.

🔹 5. Notas de seguridad
Los ARNs sensibles y nombres de buckets se gestionan desde SSM Parameter Store, nunca hardcodeados en el repo.

El OIDC role tiene permisos mínimos para cloudformation, s3, iam:PassRole y ssm:GetParameter.

Los roles de CodePipeline/CodeBuild tienen permisos limitados al bucket de artifacts y recursos de despliegue.


########################################################################################
{
  "OIDC_ROLE": {
    "RoleName": "gbm-connect-bootstrap-oidc-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
            },
            "StringLike": {
              "token.actions.githubusercontent.com:sub": [
                "repo:mmacchia-nubity/gbm-connect-bootstrap:ref:refs/heads/*",
                "repo:mmacchia-nubity/gbm-connect-bootstrap:environment:*"
              ]
            }
          }
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        { "Effect": "Allow", "Action": "cloudformation:*", "Resource": "*" },
        { "Effect": "Allow", "Action": "s3:*", "Resource": "*" },
        { "Effect": "Allow", "Action": "iam:PassRole", "Resource": "*" },
        { "Effect": "Allow", "Action": "ssm:GetParameter", "Resource": "*" }
      ]
    }
  },

  "STG_PIPELINE_ROLE": {
    "RoleName": "gbm-connect-pipeline-stg-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "codepipeline.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:GetObject","s3:GetObjectVersion","s3:PutObject","s3:DeleteObject"],
          "Resource": "arn:aws:s3:::gbm-connect-artifacts-stg/*"
        },
        {
          "Effect": "Allow",
          "Action": ["codebuild:BatchGetBuilds","codebuild:StartBuild"],
          "Resource": "*"
        }
      ]
    }
  },

  "STG_BUILD_ROLE": {
    "RoleName": "gbm-connect-build-stg-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "codebuild.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        { "Effect": "Allow", "Action": "s3:*", "Resource": "arn:aws:s3:::gbm-connect-artifacts-stg/*" },
        { "Effect": "Allow", "Action": "cloudformation:*", "Resource": "*" },
        { "Effect": "Allow", "Action": "iam:PassRole", "Resource": "*" },
        { "Effect": "Allow", "Action": "secretsmanager:GetSecretValue", "Resource": "*" }
      ]
    }
  },

  "STG_RELEASE_ROLE": {
    "RoleName": "gbm-connect-release-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "codebuild.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        { "Effect": "Allow", "Action": "secretsmanager:GetSecretValue", "Resource": "*" },
        { "Effect": "Allow", "Action": "s3:*", "Resource": "arn:aws:s3:::gbm-connect-artifacts-stg/*" }
      ]
    }
  },

  "PRD_PIPELINE_ROLE": {
    "RoleName": "gbm-connect-pipeline-prd-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "codepipeline.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:GetObject","s3:GetObjectVersion","s3:PutObject","s3:DeleteObject"],
          "Resource": "arn:aws:s3:::gbm-connect-artifacts-prd/*"
        },
        {
          "Effect": "Allow",
          "Action": ["codebuild:BatchGetBuilds","codebuild:StartBuild"],
          "Resource": "*"
        }
      ]
    }
  },

  "PRD_BUILD_ROLE": {
    "RoleName": "gbm-connect-build-prd-role",
    "TrustPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "codebuild.amazonaws.com" },
          "Action": "sts:AssumeRole"
        }
      ]
    },
    "PermissionsPolicy": {
      "Version": "2012-10-17",
      "Statement": [
        { "Effect": "Allow", "Action": "s3:*", "Resource": "arn:aws:s3:::gbm-connect-artifacts-prd/*" },
        { "Effect": "Allow", "Action": "cloudformation:*", "Resource": "*" },
        { "Effect": "Allow", "Action": "iam:PassRole", "Resource": "*" },
        { "Effect": "Allow", "Action": "secretsmanager:GetSecretValue", "Resource": "*" }
      ]
    }
  }
}

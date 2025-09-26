# gbm-connect-bootstrap
STG
aws ssm put-parameter --name "/gbm/stg/artifact-bucket" \
  --value "gbm-connect-artifacts-stg" --type String

aws ssm put-parameter --name "/gbm/stg/pipeline-role" \
  --value "arn:aws:iam::825765398662:role/gbm-connect-pipeline-stg-role" --type String

aws ssm put-parameter --name "/gbm/stg/build-role" \
  --value "arn:aws:iam::825765398662:role/gbm-connect-build-stg-role" --type String

aws ssm put-parameter --name "/gbm/stg/release-role" \
  --value "arn:aws:iam::825765398662:role/gbm-connect-release-role" --type String



PRD

aws ssm put-parameter --name "/gbm/prd/artifact-bucket" \
  --value "gbm-connect-artifacts-prd" --type String

aws ssm put-parameter --name "/gbm/prd/pipeline-role" \
  --value "arn:aws:iam::825765398662:role/gbm-connect-pipeline-prd-role" --type String

aws ssm put-parameter --name "/gbm/prd/build-role" \
  --value "arn:aws:iam::825765398662:role/gbm-connect-build-prd-role" --type String

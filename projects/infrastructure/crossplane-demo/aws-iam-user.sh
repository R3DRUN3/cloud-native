echo "create a new IAM user"
IAM_USER=test-user
aws iam create-user --user-name $IAM_USER

echo "grant the IAM user the necessary permissions"
aws iam attach-user-policy --user-name $IAM_USER --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

echo "create a new IAM access key for the user"
aws iam create-access-key --user-name $IAM_USER > creds.json
echo "assign the access key values to environment variables"
ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId creds.json)
AWS_SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey creds.json)
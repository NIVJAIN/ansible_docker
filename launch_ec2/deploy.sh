#!/bin/sh
CONFIG="state-bucket.config"
# TFVARS="production.tfvars"
if [ "$1" = "initialize" ];then
    echo "Terraform Initiazling........."
    terraform init -backend-config=${CONFIG}
elif [ "$1" = "plan" ];then
    terraform init -backend-config=${CONFIG}
    terraform plan 
elif [ "$1" = "apply" ];then
    terraform init -backend-config=${CONFIG}
    terraform apply  -auto-approve
elif [ "$1" = "destroy" ];then
    terraform init -backend-config=${CONFIG}
    terraform destroy  -auto-approve
fi


# #!/bin/sh
# CONFIG="state-bucket.config"
# TFVARS="production.tfvars"
# if [ "$1" = "initialize" ];then
#     echo "Terraform Initiazling........."
#     terraform init -backend-config=${CONFIG}
# elif [ "$1" = "plan" ];then
#     terraform init -backend-config=${CONFIG}
#     terraform plan -var-file=${TFVARS}
# elif [ "$1" = "deploy" ];then
#     terraform init -backend-config=${CONFIG}
#     terraform apply -var-file=${TFVARS} -auto-approve
# elif [ "$1" = "destroy" ];then
#     terraform init -backend-config=${CONFIG}
#     terraform destroy -var-file=${TFVARS} -auto-approve
# fi




# #!/bin/bash 
# CONFIG="state.config"
# TFVARS="var.tfvars"
# echo "${PWD##*/}"
# AWS_BUC_NAME="${PWD##*/}"
# GCC_BUCKET_NAME=$AWS_BUC_NAME-"gcc"
# echo $BUCKET_NAME
# CREATOR="Jain"
# REQUESTOR=JAIN
# # BUCKET_NAME="dcai-dev-mediacorpus-s3-gcc"
# # BUC_NAME="dcai-dev-mediacorpus-s3"

# STATE_CONFIG_CREATION(){
#     echo "Creating state.config for s3 bucket terraform stateManagement ....."
#     # aws s3api get-bucket-policy --bucket $AWS_BUC_NAME --query Policy --profile "jainaws" --output text > policy.json
#     # aws s3api get-bucket-tagging --bucket  $AWS_BUC_NAME --profile "jainaws" --output json > tags.json
#     echo 'key="S3-BUCKET-TFSTATE/'$GCC_BUCKET_NAME'.tfstate"' >state.config
#     echo 'bucket="terraform-s3bucket-states-gcc"' >> state.config
#     echo 'region="ap-southeast-1"' >> state.config
# }

# VARS_DOT_TF_CREATION(){
#     echo "Creating var.tfvars file"
#     echo 'agency_name="na"' >var.tfvars
#     echo 'project_code="na"' >>var.tfvars
#     echo 'app_name="na"' >>var.tfvars
#     echo 'purpose="na"' >>var.tfvars
#     echo 'env_name="dev"' >>var.tfvars
#     echo 'bucket_name="'$GCC_BUCKET_NAME'"' >>var.tfvars
#     echo 'requestor="'$REQUESTOR'"' >>var.tfvars
#     echo 'creator="'$CREATOR'"' >>var.tfvars
#     terraform fmt
# }



# if [ $1 = "plan" ]; then 
#     echo "Rinning terraform plan"
#     terraform init -backend-config=${CONFIG}
#     terraform plan -var-file=${TFVARS}
# elif [ $1 = "apply" ]; then
#     INIT 
#     terraform init -backend-config=${CONFIG}    
#     terraform apply -var-file=${TFVARS} -auto-approve
#     rm -rf .terraform*
# elif [ $1 = "destroy" ]; then 
#     terraform init -backend-config=${CONFIG}    
#     terraform destroy -var-file=${TFVARS} -auto-approve
# elif [ $1 = "copy" ]; then

# fi








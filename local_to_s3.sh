#!/bin/bash

VAL_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$VAL_DIR" ]]; then
        VAL_DIR="$PWD";
fi

aws s3api help > /dev/null 2>&1
if [ ! $? == 0 ]; then

echo "Installing aws cli ..."
wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip  > /dev/null 2>&1
echo "A" | unzip awscli-bundle.zip  > /dev/null 2>&1
echo "Configuring aws cli ..."
python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws  > /dev/null 2>&1
python3 ./awscli-bundle/install -b ~/bin/aws  > /dev/null 2>&1
python3 ./awscli-bundle/install -h  > /dev/null 2>&1
fi

storage_type=$(awk ''/^storage_type:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)

remote_storage_type=$(awk ''/^remote_storage_type:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)
base_dir=$(awk ''/^base_dir:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)
aws_access_key=$(awk ''/^s3_access_key:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)
aws_secret_key=$(awk ''/^s3_secret_key:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)
aws_default_region=$(awk ''/^aws_default_region:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)
output_bucket=$(awk ''/^s3_output_bucket:' /{ if ($2 !~ /#.*/) {print $2}}' aws_s3_config.yml)
source_output_directory=$(awk ''/^source_output_directory:' /{ if ($2 !~ /#.*/) {print $2}}' migrate_config.yml)


sudo apt install awscli -y

export AWS_ACCESS_KEY_ID=$aws_access_key
export AWS_SECRET_ACCESS_KEY=$aws_secret_key


if [[ $storage_type = "local" ]] && [[ $remote_storage_type = "s3" ]]; then
irbucket=$(aws s3 sync $source_output_directory s3://$output_bucket)
fi


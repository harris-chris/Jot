# Load variables from config.json
source ./_load_config.sh

# Build the image
sudo docker build --rm --no-cache --tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME .

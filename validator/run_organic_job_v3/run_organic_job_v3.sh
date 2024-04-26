#!/bin/bash
set -eux -o pipefail

# In order for this script to work, a docker image pushed by it must be a public one. It's up to the
# user to perform a relevant `docker login` before executing. Both DockerHub and GitHub Packages provide free
# public image hosting. See
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic
# or
# https://docs.docker.com/security/for-developers/access-tokens/#use-an-access-token
# execute it from the directory that has your docker-compose.yml for running a validator

set -e
if [ -z "$IMAGE_NAME_AND_TAG" ]
then
  echo "IMAGE_NAME_AND_TAG is not set. Please specify it before using this script."
  exit 1
fi

if [ -z "$MINER_UID" ]
then
  echo "MINER_UID is not set. Please specify it before using this script."
  exit 1
fi

if [ -z "$EPOCHS" ]
then
  echo "EPOCHS is not set. Please specify it before using this script."
  exit 1
fi


ORIG_DIR="$PWD"
cd "$(dirname "${BASH_SOURCE[0]}")" 

echo '
FROM python:3.11-slim
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip install transformers Pillow requests
COPY download_datasets.py download_datasets.py
RUN python download_datasets.py
COPY train_mnist.py train_mnist.py
ARG EPOCHS
ENV EPOCHS=$EPOCHS
ENTRYPOINT python train_mnist.py $EPOCHS
' > Dockerfile

docker build -t "$IMAGE_NAME_AND_TAG" --build-arg EPOCHS="$EPOCHS" .

docker push "$IMAGE_NAME_AND_TAG"

cd "$ORIG_DIR"

docker-compose exec validator-runner docker-compose exec celery-worker /bin/bash -c \
"SYNTHETIC_JOB_GENERATOR='compute_horde_validator.validator.synthetic_jobs.generator.cli:CLIJobGenerator' python manage.py debug_run_organic_job \
--miner_uid $MINER_UID \
--timeout 900 \
--base_docker_image_name $IMAGE_NAME_AND_TAG \
--docker_image_name $IMAGE_NAME_AND_TAG \
--docker_run_options_preset 'nvidia_all' \
--docker_run_cmd '[]'"

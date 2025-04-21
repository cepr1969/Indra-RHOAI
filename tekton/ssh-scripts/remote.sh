#!/usr/bin/env sh

shopt -s inherit_errexit
set -eu -o pipefail

source $(CDPATH= cd -- "$(dirname -- ${0})" && pwd)/common.sh

#
# Image is already created
# ${PARAMS_IMAGE}
#
phase "scp image to remote server"
scp -o StrictHostKeyChecking=no ${WORKSPACES_IMAGEDIRECTORY_PATH}/${PARAMS_IMAGE} ${SSH_USER}@${SSH_HOST}:${SSH_DIRECTORY}

phase "prepare script"
cat > ${WORKSPACES_IMAGEDIRECTORY_PATH}/deploy.sh <<EOF
# Now we neeed to create a script to execute the image

# Configuración de parámetros
NODES=${PARAMS_NODES}             # Número de nodos
TASKS=${PARAMS_TASKS}             # Número de tareas
PARTITION="interactive"           # Nombre de la partición -> interactive (max 2 días), batch (max 30 días)
WORKER="${PARAMS_WORKERS}"        # Nombre del nodo de trabajo
GPUS=${PARAMS_GPUS}               # Número de GPUs
JOB_NAME="${PARAMS_JOB_NAME}"     # Nombre del trabajo
TIME="${PARAMS_TIME}"             # Límite de tiempo -> e.g. 4 días 8 horas 04:08:00:00
COMMAND="${PARAMS_COMMAND}"

# Ejecutar el comando srun
srun -K \
    --container-mounts=/home/${SSH_USER}:/home/${SSH_USER} \
    --container-mounts=/etc/ssh/host*:/etc/ssh/ \
    --no-container-remap-root \
    --container-workdir=$(pwd) \
    --container-image="${PARAMS_IMAGE}" \
    --ntasks="\$TASKS" \
    --nodes="\$NODES" \
    --partition "\$PARTITION" \
    --nodelist "\$WORKER" \
    --gpus="\$GPUS" \
    --job-name "\$JOB_NAME" \
    --time "\$TIME" \
    --pty /bin/bash -c "\${COMMAND}"
EOF

phase
chmod +x deploy.sh

# copy to remote server
scp -o StrictHostKeyChecking=no ./deploy.sh ${SSH_USER}@${SSH_HOST}:${SSH_DIR}

phase "execute script on remote server"
ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} "chmod a+x ./deploy.sh && ./deploy.sh"

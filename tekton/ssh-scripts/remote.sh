#!/usr/bin/env sh

#
# Image is already created
# ${PARAMS_IMAGE_OUTPUT}
#

scp ${PARAMS_IMAGE_OUTPUT} ${SSH_USER}@${SSH_HOST}:${SSH_DIR}

cat > deploy.sh <<EOF
# Now we neeed to create a script to execute the image

# Configuración de parámetros
NODES=${NODES}             # Número de nodos
TASKS=${TASKS}             # Número de tareas
PARTITION="interactive"    # Nombre de la partición -> interactive (max 2 días), batch (max 30 días)
WORKER="${WORKER}"         # Nombre del nodo de trabajo
GPUS=${GPUS}               # Número de GPUs
JOB_NAME="${JOB_NAME}"     # Nombre del trabajo
TIME="${TIME}"             # Límite de tiempo -> e.g. 4 días 8 horas 04:08:00:00

# Ejecutar el comando srun
srun -K \
    --container-mounts=/home/${SSH_USER}:/home/${SSH_USER} \
    --container-mounts=/etc/ssh/host*:/etc/ssh/ \
    --container-workdir=$(pwd) \
    --nodes="\$NODES" \
    --container-image="${PARAMS_IMAGE_OUTPUT}" \
    --ntasks="\$TASKS" \
    --nodes="\$NODES" \
    --partition "\$PARTITION" \
    --nodelist "\$WORKER" \
    --gpus="\$GPUS" \
    --job-name "\$JOB_NAME" \
    --no-container-remap-root \
    --time "\$TIME" \
    --pty /bin/bash -c "service ssh start && /bin/bash" 
EOF

chmod +x deploy.sh

# copy to remote server
scp deploy.sh ${SSH_USER}@${SSH_HOST}:${SSH_DIR}

ssh ${SSH_USER}@${SSH_HOST} "chmod a+x ./deploy.sh && ./deploy.sh"

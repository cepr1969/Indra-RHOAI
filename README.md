# Indra-RHOAI

## SuperPOD Integration

Se han creado una serie de tareas (Tekton Tasks) y pipelines (Tekton Pipelines) para facilitar la integración con OpenShift Pipelines y con Data Science Pipelines en el namespace `superpod-integartion`.

Las tareas son:
- `fetch-repository` para copiar el contenido de un repositorio que contenga un `Dockerfile` o `Containerfile` para generar una imagen de contenedor que contenga todo lo necesario para ejecutarse en el SuperPOD. Hemos seguido el ejemplo y el repositorio es este mismo (http://github.com/cepr1969/Indra-RHOAI).
- `build-image` para crear la imagen del contenedor a partir de lo que se ha copiado en la tarea anterior. También se hace el push a un registry (para que luego el enroot pueda descargarse la imagen)
- `enroot-image` para crear la imagen en formato .sqfs a partir de la imagen subida al registry en el paso anterior.
- `scp-run-collect` para copiar la imagen a SuperPOD, preparar un script para ejecutarla, copiar el script, ejecutar el script en el SuperPOD y recuperar los resultados.

De momento lo tenemos con dos pipelines por que necesitan privilegios distintos:
- `superpod-phase1`:
    - Descripción: ejecuta las dos primeras tareas
    - Parámetros
        - IMAGE: nombre de la imagen del contenedor en formato sqfs
        - git-url: URL del repositorio git, por ejemplo `'https://github.com/cepr1969/Indra-RHOAI'`
        - git-revision
        - CONTAINERFILE_PATH: direcotrio donde está el Dockerfile, referido a la raiz del repositorio, por ejemplo `SuperPOD`
        - SUBDIRECTORY: directorio de donde se saca el contenido de la image, referido a la raiz del repositorio, por ejemplo `SuperPOD`
        - DESTINATION_IMAGE_URL: destino de la imagen en el formato $REGISTRY_NAME:$REGISTRY_PORT/$REPO_IMAGE:$IMAGE_TAG, por ejemplo `'registry.mlops.software.bl.platform:8443/superpod/superpod:latest'`
  - Volúmenes:
        - `shared-workspace`: PersistentVolumeClaim donde se copia el repositorio
        - `ssh-directory`: secreto con el directorio .ssh para acceder al SuperPOD, por ejemplo `ssh-directory-cpiedraf`
        - `docker-config`: secreto con el .docker/config.json con las credenciales para hacer el push de la imagen al repositorio, por ejmplo `docker-credentials`
- `superpod-phase2`:
    - Descripción: ejecuta las dos últimas tareas
    - Parámetros:
        - IMAGE: nombre de la imagen del contenedor en formato sqfs
        - git-url: URL del repositorio git, por ejemplo `'https://github.com/cepr1969/Indra-RHOAI'`
        - git-revision
        - CONTAINERFILE_PATH: direcotrio donde está el Dockerfile, referido a la raiz del repositorio, por ejemplo `SuperPOD`
        - SUBDIRECTORY: directorio de donde se saca el contenido de la image, referido a la raiz del repositorio, por ejemplo `SuperPOD`
        - DESTINATION_IMAGE_URL: destino de la imagen en el formato $REGISTRY_NAME:$REGISTRY_PORT/$REPO_IMAGE:$IMAGE_TAG, por ejemplo `'registry.mlops.software.bl.platform:8443/superpod/superpod:latest'`
        - SSH_USER:
        - SSH_HOST:
        - SSH_DIRECTORY:
        - NODES: Número de nodos
        - TASKS: Número de tareas
        - WORKER: Lista con los nombre de los nodos de trabajo
        - GPUS: Número de GPUs
        - JOB_NAME: Nombre del trabajo
        - TIME: Límite de tiempo -> e.g. 4 días 8 horas 04:08:00:00
        - COMMAND: Comando a ejecutar
    - Volúmenes:
        - `shared-workspace`: PersistentVolumeClaim donde se copia la imagen y los resultados
        - `ssh-directory`: secreto con el directorio .ssh para acceder al SuperPOD, por ejemplo `ssh-directory-cpiedraf`
        - `docker-config`: secreto con el .docker/config.json con las credenciales para hacer a la imagen en el repositorio, por ejemplo `docker-credentials`

Para crear el secret para el ssh tenemos que hacer, por ejemplo:
```bash
oc create secret generic ssh-directory-helper \
    --namespace superpod-integration \
	--from-file="config=${HOME}/.ssh/config" \
	--from-file="authorized_keys=${HOME}/.ssh/authorized_keys" \
    --from-file="id_rsa=${HOME}/.ssh/helper_rsa" \
    --from-file="known_hosts=${HOME}/.ssh/known_hosts"
```
El secret para acceder al registry es
```bash
oc create secret docker-registry docker-credentials \
    --namespace superpod-integration \
    --from-file=${HOME}/.docker/config.json
```

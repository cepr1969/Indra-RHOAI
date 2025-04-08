####
#### Referencia
# https://kserve.github.io/website/latest/sdk_docs/sdk_doc/
# https://github.com/kserve/website/blob/main/docs/sdk_docs/sdk_doc.md
# https://github.com/kserve/website/blob/main/docs/sdk_docs/docs/KServeClient.md
#### Ejemplo https://github.com/kserve/website/blob/main/docs/sdk_docs/samples/kserve_sdk_v1beta1_sample.ipynb
####

from kubernetes import client
from kserve import KServeClient
from kserve import constants
from kserve import utils
from kserve import V1beta1InferenceService
from kserve import V1beta1InferenceServiceSpec
from kserve import V1beta1PredictorSpec
from kserve import V1beta1TFServingSpec
from kserve import V1beta1ModelSpec
from kserve import V1beta1ModelFormat
from kserve import V1beta1StorageSpec

####api_version = constants.KSERVE_GROUP + "/" + kserve_version
api_version = constants.KSERVE_V1BETA1

name="my1stmodel"
namespace = "fpgpocnotebooks"
labels = {'opendatahub.io/dashboard': 'true'}
annotations = {}
annotations["openshift.io/display-name"] = "my1stmodel"
annotations["serving.kserve.io/deploymentMode"] = "ModelMesh"

isvc = V1beta1InferenceService(
    api_version=api_version,
    kind=constants.KSERVE_KIND,
    metadata=client.V1ObjectMeta(
        name=name,
        namespace=namespace,
        labels=labels,
        annotations=annotations
        ),
    spec=V1beta1InferenceServiceSpec(
        predictor=V1beta1PredictorSpec(
            model=V1beta1ModelSpec(
                model_format=V1beta1ModelFormat(
                    name="onnx",
                    version="1"
                ),
                runtime="triton",
                storage=V1beta1StorageSpec(
                    key="aistudiopoc",
                    path="model/diabetes.onnx"
                )
            )
        )
    ),
)


KServe = KServeClient()
KServe.create(isvc, watch=True)

KServe.get(name=name, namespace=namespace, watch=True, timeout_seconds=120)

KServe.wait_isvc_ready(name=name, namespace=namespace)

KServe.delete(name=name, namespace=namespace)

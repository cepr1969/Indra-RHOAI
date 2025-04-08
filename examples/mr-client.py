from model_registry import ModelRegistry
from model_registry import utils


server_address="https://modelregistry1-rest.apps.mlops.software.bl.platform"
author="Carlos Piedrafita"
rootCA="/home/cpiedraf/config/apps-mlops-software-bl-platform-chain.pem"

"""
From github.com/kubeflow/model-registry/clients/python/src/model_registry/_client.py
        server_address: str,
        port: int = 443,
        *,
        author: str,
        is_secure: bool = True,
        user_token: str | None = None,
        user_token_envvar: str = DEFAULT_USER_TOKEN_ENVVAR,
        custom_ca: str | None = None,
        custom_ca_envvar: str | None = None,
        log_level: int = logging.WARNING,
"""

registry = ModelRegistry(server_address, author=author, custom_ca=rootCA)

"""
model = registry.register_model(
    "my-model",  # model name
    uri=utils.s3_uri_from("path/to/model", "my-bucket"),
    version="2.0.0",
    description="lorem ipsum",
    model_format_name="onnx",
    model_format_version="1",
    storage_key="my-data-connection",
    metadata={
        # can be one of the following types
        "int_key": 1,
        "bool_key": False,
        "float_key": 3.14,
        "str_key": "str_value",
    }
)

model = registry.register_model(
    "my-model",  # model name
    "https://storage-place.my-company.com",  # model URI
    version="2.0.0",
    description="lorem ipsum",
    model_format_name="onnx",
    model_format_version="1",
    storage_key="my-data-connection",
    storage_path="path/to/model",
    metadata={
        # can be one of the following types
        "int_key": 1,
        "bool_key": False,
        "float_key": 3.14,
        "str_key": "str_value",
    }
)
"""

for model in registry.get_registered_models():
    print(model)


model = registry.get_registered_model("diabetes")
print(model)

"""
version = registry.get_model_version("my-model", "2.0.0")
print(version)

experiment = registry.get_model_artifact("my-model", "2.0.0")
print(experiment)

# change is not reflected on pushed model version
version.description = "Updated model version"

# you can update it using
registry.update(version)
"""

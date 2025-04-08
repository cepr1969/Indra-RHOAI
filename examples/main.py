import os
import yaml

def generate_deployment_yaml():
    # Read the statefulset definition from the YAML file
    with open('signal-processing-statefulset.yaml', 'r') as file:
        statefulset = yaml.safe_load(file)

    # Modify the statefulset definition as needed for the deployment
    statefulset['kind'] = 'Deployment'
    statefulset['metadata']['name'] = 'signal-processing-deployment'
    statefulset['spec']['selector'] = statefulset['spec'].pop('selector')
    statefulset['spec']['template'] = statefulset['spec'].pop('template')
    statefulset['spec']['replicas'] = 1

    # Write the modified definition to a new YAML file
    with open('signal-processing-deployment.yaml', 'w') as file:
        yaml.dump(statefulset, file)

if __name__ == "__main__":
    generate_deployment_yaml()


import yaml

def generate_deployment_yaml():
    # Read the statefulset definition from the YAML file
    with open('signal-processing-statefulset.yaml', 'r') as file:
        statefulset = yaml.safe_load(file)

    # Remove the container named 'oauth-proxy'
    containers = statefulset['spec']['template']['spec']['containers']
    statefulset['spec']['template']['spec']['containers'] = [container for container in containers if container['name'] != 'oauth-proxy']

    # Write the modified definition to a new YAML file
    with open('signal-processing-statefulset-modified.yaml', 'w') as file:
        yaml.dump(statefulset, file)

if __name__ == "__main__":
    generate_deployment_yaml()
    
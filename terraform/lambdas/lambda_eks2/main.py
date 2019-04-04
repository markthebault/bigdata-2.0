from auth import EKSAuth
from kubernetes import client, config
import yaml
import boto3
import os.path

# Configure your cluster name and AWS_REGION here
KUBE_FILEPATH = '/tmp/kubeconfig'
CLUSTER_NAME = os.environ['CLUSTER_NAME']
AWS_REGION = os.environ['AWS_REGION']

# We assuem that when the Lambda container is reused, a kubeconfig file exists.
# If it does not exist, it creates the file.

if not os.path.exists(KUBE_FILEPATH):
    
    kube_content = dict()
    # Get data from EKS API
    eks_api = boto3.client('eks',region_name=AWS_REGION)
    cluster_info = eks_api.describe_cluster(name=CLUSTER_NAME)
    certificate = cluster_info['cluster']['certificateAuthority']['data']
    endpoint = cluster_info['cluster']['endpoint']

    # Generating kubeconfig
    kube_content = dict()
    
    kube_content['apiVersion'] = 'v1'
    kube_content['clusters'] = [
        {
        'cluster':
            {
            'server': endpoint,
            'certificate-authority-data': certificate
            },
        'name':'kubernetes'
                
        }]

    kube_content['contexts'] = [
        {
        'context':
            {
            'cluster':'kubernetes',
            'user':'aws'
            },
        'name':'aws'
        }]

    kube_content['current-context'] = 'aws'
    kube_content['Kind'] = 'config'
    kube_content['users'] = [
    {
    'name':'aws',
    'user':'lambda'
    }]

    print(kube_content)
    # Write kubeconfig
    with open(KUBE_FILEPATH, 'w') as outfile:
        yaml.dump(kube_content, outfile, default_flow_style=False)

def handler(event, context):

    # Get Token
    eks = EKSAuth(CLUSTER_NAME, AWS_REGION)
    token = eks.get_token()
    print("TOKEN: "+token)
    # Configure
    config.load_kube_config(KUBE_FILEPATH)
    configuration = client.Configuration()
    configuration.api_key['authorization'] = token
    configuration.api_key_prefix['authorization'] = 'Bearer'
    # API
    api = client.ApiClient(configuration)
    v1 = client.CoreV1Api(api)
    
    # Get all the pods
    ret = v1.list_namespaced_pod("default")

    for i in ret.items:
        print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))



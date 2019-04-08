from kubernetes import client, config
import yaml
import boto3
import os.path
import base64
import string
import random
import re
from botocore.signers import RequestSigner

# Configure your cluster name and AWS_REGION here
KUBE_FILEPATH = '/tmp/kubeconfig'
CLUSTER_NAME = os.environ['CLUSTER_NAME']
AWS_REGION = os.environ['AWS_REGION']

def get_token(cluster_id):
    """
    Return bearer token
    """
    session = boto3.session.Session()
    #Get ServiceID required by class RequestSigner
    client = session.client("sts",region_name=AWS_REGION)
    service_id = client.meta.service_model.service_id

    signer = RequestSigner(
        service_id,
        session.region_name,
        'sts',
        'v4',
        session.get_credentials(),
        session.events
    )

    params = {
        'method': 'GET',
        'url': 'https://sts.{}.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15'.format(AWS_REGION),
        'body': {},
        'headers': {
            'x-k8s-aws-id': cluster_id
        },
        'context': {}
    }

    # print("params: "+str(params))

    signed_url = signer.generate_presigned_url(
        params,
        region_name=AWS_REGION,
        expires_in=60,
        operation_name=''
    )
    # print("SIGNED_URL: "+signed_url)

    base64_url = base64.urlsafe_b64encode(signed_url.encode('utf-8')).decode('utf-8')
    token = 'k8s-aws-v1.' + re.sub(r'=*', '', base64_url)
    # print("token: "+token)
    return token



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
    token = get_token(CLUSTER_NAME)
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

    if not ret.items:
        print("No Pods Found in namespace default")

    for i in ret.items:
        print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))



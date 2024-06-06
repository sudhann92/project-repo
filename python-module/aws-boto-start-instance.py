import boto3
import sys
import time
# input value 'ansible-controller' while running the instance
#import json
ec2_client = boto3.client('ec2', region_name = "us-east-1")
instances = ec2_client.describe_instances()
for reservation in instances['Reservations']:
    for instance in reservation["Instances"]: 
        if instance["Tags"][0]["Value"] == sys.argv[1]:
            response = ec2_client.start_instances(InstanceIds=[instance["InstanceId"]])
            istance_id = instance["InstanceId"]

while True:
    print('checking the status........')
    time.sleep(3)
    status_value = ec2_client.describe_instance_status(InstanceIds=[istance_id])
    if len(status_value['InstanceStatuses']) != 0:
        if status_value['InstanceStatuses'][0]['InstanceState']['Name'] == 'running':
            print(f"{sys.argv[1]} EC2 Instance got:- {status_value['InstanceStatuses'][0]['InstanceState']['Name']}")
            break

capture_public_dns= ec2_client.describe_instances(InstanceIds=[istance_id])
print(capture_public_dns["Reservations"][0]["Instances"][0]["PublicDnsName"])
print ("Press Enter to continue ..." )
input()
# input value 'ansible-controller' while running the instance
import boto3
import sys, time
ec2_client = boto3.client('ec2', region_name = "us-east-1")
instances = ec2_client.describe_instances()
for reservation in instances['Reservations']:
    for instance in reservation["Instances"]: 
        if instance["Tags"][0]["Value"] == sys.argv[1]:
            jenkin_id = instance["InstanceId"]
            response = ec2_client.stop_instances(InstanceIds=[instance["InstanceId"]])

while True:
    print('checking the status........')
    status_value = ec2_client.describe_instance_status(InstanceIds=[jenkin_id])
    if len(status_value['InstanceStatuses']) != 0:
        if status_value['InstanceStatuses'][0]['InstanceState']['Name'] == 'stopping':
            print(f"{sys.argv[1]} EC2 Instance got:- {status_value['InstanceStatuses'][0]['InstanceState']['Name']}")
        break
    else:
        print(f'{sys.argv[1]} already been in stopped state')
    break
    time.sleep(4)
    
print ("Press Enter to continue ..." )
input()
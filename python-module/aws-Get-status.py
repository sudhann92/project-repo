import boto3
ec2_client = boto3.client('ec2', region_name = "us-east-1")
status_value = ec2_client.describe_instance_status(InstanceIds=["i-00c88e24929a2e564"])
print(status_value)
import boto3
#import json
ec2_client = boto3.client('ec2', region_name = "us-east-1")
instances = ec2_client.describe_instances()
for reservation in instances['Reservations']:
    for instance in reservation["Instances"]: 
        print("Instance ID: ", instance["InstanceId"])
        print("Image ID: ", instance["ImageId"])
        print("Instance Type: ", instance["InstanceType"])
        #print("public ip: ",instance["PublicIpAddress"])
        print("private ip: ",instance["PrivateIpAddress"])
        print("AZ: ", instance["Placement"]["AvailabilityZone"])
        print("Name:" , instance["Tags"][0]["Value"])
    print("\n")



#print(instances['Reservations'][0][0])

# This script would do below tasks
# 1. Create User
# 2. Edit user
# 3. Delete user

# 1. Create user
# print("Creating a user")
# try:
#     create_user = iam_client.create_user(
#         UserName='testing'
#     )
#     print("Created a user. Below is the result")
#     print(create_user)
# except Exception as e:
#     print(e)
#     pass


# # 2. Edit/Update a user
# print('Updating user name')
# update_user = iam_client.update_user(
#     UserName='Jeff-Bernard',
#     NewUserName='testing-with-script'
# )
# print('username updated')
# print(update_user)


# # 3. Delete a user
# print('Deleting user')
# delete_user = iam_client.delete_user(
#     UserName='Bernard-Shaw'
# )
# print('user deleted')
# print(delete_user)
# print('Exiting the program')
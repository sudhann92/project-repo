#Documention for this script#
#importing the subprocess library for store the command output json for manipulate json data
#csv for create CSV file
#Input need for this check below steps
#create text file with name of  copied the credential name in that file line by line format abd pass in script like below
#python3 /home/g83141-udm/cred-user-name-v1.py "name of file path.txt"
#pass this file path in below [with] keyword"
#Once script completed output file will get generate in current path file name "cred_name_file.csv"
import subprocess, json, csv, sys
def cred_user_name_value(file_name):
    user_value = [['credential_name','credential_type','user_name']]
    #with open("cred_name_file.txt", "r") as a_file:
    with open(file_name, "r") as a_file:
        for cred in a_file:
            cmd = 'tower-cli credential list -n {} -f json'.format(cred.strip())
            pro_value = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            rc = pro_value.wait()
            output,error_v = pro_value.communicate()
            #new_out = output
            if len(output) > 0:
                data = json.loads(output)
                if data['count'] > 0:
                        for value in data['results']:
                            if 'username' in value['inputs']:
                                user_ = [cred.strip(),value['summary_fields']['credential_type']['name'],value['inputs']['username']]
                                user_value.append(user_)
                            else:
                                user_ = [cred.strip(),value['summary_fields']['credential_type']['name'],'']
                                user_value.append(user_)
                else:
                    user_ = [cred.strip(),'','']
                    user_value.append(user_)
            else:
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                print(f"Error occured on this { cred.strip() } credential name kindly check manually")
                print(f"\nError_code: {error_v}")
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

    with open('cred_name_file.csv', 'w', newline='') as f:
        write_val = csv.writer(f)
        write_val.writerows(user_value)

    print("Updated the Credential User Name Value in this file:",'\033[32m cred_name_file.csv \033[0m' )


if __name__ == "__main__":
    cred_user_name_value(sys.argv[1])

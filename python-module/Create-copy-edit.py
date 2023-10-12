import sys
import shutil

# created for Test branch when we used to develop we need to replace test as develop
#copied_location= "/tmp/new_file/%s.yml" % sys.argv[1]

def copy_file_name(org_name):
    for each_org in org_name:
        copied_location= "/tmp/new_file/aap_{0}_sync_plan_{1}.yml".format(each_org,branch_name)
        shutil.copyfile(original_plan,copied_location)
        with open(copied_location, 'r') as file:
              # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
              data = file.read()
    # Searching and replacing the text
    # using the replace() function
              data = data.replace('ARC746', each_org)
        with open(copied_location, 'w') as file:
    # Writing the replaced data in our
    # text file
              file.write(data)
    print("Text replaced successfully for customer file in /tmp/new_file/")

def perm_file_name(org_name):
    for each_org in org_name:
        #copied_location= "/tmp/permission/aap_%s_sync_permission_test.yml" % each_org
        copied_location= "/tmp/permission/aap_{0}_sync_permission_{1}.yml".format(each_org,branch_name)
        shutil.copyfile(original_perm,copied_location)
        with open(copied_location, 'r') as file:
              # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
              data = file.read()
    # Searching and replacing the text
    # using the replace() function
              data = data.replace('ARC746', each_org)
        with open(copied_location, 'w') as file:
    # Writing the replaced data in our
    # text file
              file.write(data)
    print("\n Text replaced successfully for permission file /tmp/permission/")


def append_bamboo_file(org_name):
    for each_org in org_name:
        new_content = "--- \n!include 'plans/customer/aap_{0}_sync_plan_{1}.yml' \n---\n!include 'permissions/customer/aap_{0}_sync_permission_{1}.yml'\n".format(each_org, branch_name)
        with open(original_bamboo, 'a') as file:
            #Appened the content of the file
            file.write(new_content)
            #write the content in the same file
    print('\n New content added in {}'.format(original_bamboo))


def main():
    copy_file_name(list_value)
    perm_file_name(list_value)
    append_bamboo_file(list_value)
    

#org_list = "Default,AWX,ARC746"
# original_plan= '%s'% sys.argv[1]  #plan file 
# original_perm = '%s'% sys.argv[2]  #permission file
# original_bamboo = '%s'% sys.argv[3] #'/tmp/bamboo.yml' bamboo file
# branch_name = '%s' % sys.argv[4] # provide branch name

original_plan= str(input("Enter the Full path of plan yaml file?:"))
original_perm = str(input("Enter the Full path of permission yaml file?:"))
original_bamboo = str(input("Enter the Full path of bamboo yaml file?:"))
branch_name = str(input("Enter the branch name in lower case?:"))


org_list = "xxx,yyy,zzzz,PPP"
list_value = org_list.split(',')

if __name__ == "__main__":
    main()

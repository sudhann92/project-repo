import re
import pathlib
import shutil

def patter_match(org_name):
    copied_location= "roles-{}-new.yml.txt".format(branch_name)
    shutil.copyfile(file_location,copied_location)
    #append_string = ''
    for _name_org in org_name:
        append_string = ''
        match_pattern= r'Below are set of default roles to be given to the admin team of an organization  {}#'.format(_name_org)
        for _yaml_name in yaml_temp_name:
            append_string += "\n  - job_template: '{1}'\n    team: '{0}_Admin_User_Group'\n    role: execute \n\n  - job_template: '{1}'\n    team: '{0}_Admin_User_Group'\n    role: read \n".format(_name_org, _yaml_name)
        with open(copied_location, 'r+') as files:
            lines = files.readlines()
            for i,line in enumerate(lines):
                match=re.search(match_pattern, line)
                if match:
                    new_line=line[:match.end()] + append_string + line[match.end():]
                    lines[i]=new_line
                    #append_string.clear()
            files.seek(0)
            files.writelines(lines)
            files.truncate()
            

def main():
    patter_match(list_value)

path = str(input("Enter the Path:")) # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
branch_name = str(input("Enter the branch name in lower case?:"))
file_location = pathlib.Path(path)
#file_location= str(input("Enter the Full path of file?:"))
org_list = "xxx,yy,bb"
yaml_temp_name = ["list value"]
list_value = org_list.split(',')


if __name__ == "__main__":
    main()



def appned_new(org_name,env_name):
    append_string = ''
    for _name_org in org_name:
        append_string +=  '\n"CN=sec-{0}-ansible-platform-org-admin-{1},OU=AZURE,OU=_Common-Access,OU=Groups,OU=_CORP,DC=oneadr,DC=net",'  '\n"CN=sec-{0}-ansible-platform-org-execute-{1},OU=AZURE,OU=_Common-Access,OU=Groups,OU=_CORP,DC=oneadr,DC=net",'.format(_name_org, env_name)
            #\n  - job_template: '{1}'\n    team: '{0}_Admin_User_Group'\n    role: execute \n\n  - job_template: '{1}'\n    team: '{0}_Admin_User_Group'\n    role: read \n".format(_name_org, _yaml_name)
    print(append_string)


def main():
    appned_new(list_value,aap_env_name)

org_list = "xxx,yyy,zzz,AAA" 
list_value = org_list.split(',')
aap_env_name = 'prod'

if __name__ == "__main__":
    main()

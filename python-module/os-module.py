import os, shutil, time

current_time = time.time()
one_Day_ago = current_time - (24*60*60)
#print(one_Day_ago)

_cwd =  os.getcwd()
one_step_backword = os.path.normpath(_cwd + os.sep + os.pardir)

for dir_name in os.listdir(one_step_backword):
    dir_path = os.path.join(one_step_backword, dir_name)

    if os.path.isdir(dir_path) and dir_name.startswith('ansible'):
        dir_modify_time = os.path.getmtime(dir_path)

        if dir_modify_time < one_Day_ago:
            shutil.rmtree(dir_path)
            print(f'Deleted {dir_path} which is older than one day')

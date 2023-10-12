import os
import re
import time
import pathlib

def file_function(file_value):
    obj = []
    count_processed_file = 0
    def get_local_time(_file):
        global local_time_value
        try:
            with open(_file,'r', encoding='utf-8',errors='ignore') as _read_content: 
                for line in _read_content:
                    if line.startswith('Local time'):
                        _time_value = line.rstrip('\n')
                        local_time_value = _time_value[_time_value.index(delimeter)+1:].strip()
                        print(f"***Local_Time: {local_time_value}***")
                        break
        except:
            print(f"This file have a problem {pathlib.Path(_file).stem} while accessing the data local time") 
    try:    
        for file_value in file:
            with open(file_value,'r', encoding='utf-8',errors='ignore') as read_content:
                print(f"***Extrating the valuable output from {pathlib.Path(file_value).stem} file raw data***")
                get_local_time(file_value)
                count_processed_file += 1 
                for line in read_content:
                    r = re.findall(r"\d{2}:\d{2}:\d{2}\.\d{3} \[T:\d+\] \{\w+:\d+\} METRIC <log\ssid='[A-Z,a-z,0-9]+'\sexpr='[a-zA-Z0-9!@#*$&()\\-_:`.+,\s]+'\slabel='[A-Z,a-z,0-9]+'\slevel='[0-9]'\s", line)
                    if r:
                        combine_value = local_time_value+' '+line
                        obj.append(combine_value) 
        timestr1 = time.strftime("%Y%m%d-%H%M%S") 
        new_file_name = "OutPut-"+timestr1+".log"      
        with open(new_file_name,'w') as opf:
            opf.write(''.join(obj))
        print(f"\nValuable data are Extracted and store in new file with the name of {new_file_name}.")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print(f"Number of actual file count from input: {len(file)}")
        print(f"Number of Processed file count: {count_processed_file}")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("Process exited with 0")
    except:
        print(f"This {pathlib.Path(file_value).stem} file have a problem while accessing the data") 

        
def main():
    file_function(file)


delimeter = ':'
while True:
    try:
        path = input("Enter the Path:") # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
        path = pathlib.Path(path)
        user_file = input("Enter the file to be extracted:")
        file = list(path.rglob(user_file))
        print(f"\n{file}\n")
        if not file:
            print("Please use the wildcard in file name:")
        else:
            pass
    except:
        print("Path not found")
    break

if __name__ =='__main__':
    main()
   

import os
import re
import time
import pathlib

class etf(object):
    def __init__(self, file):
        self.file = file
#'''Created the function (get_local_time) inside in class for get the local time in the file
#used 'with' function to open the file and read the content
#used for loop with condition to check the starting with the string 'local time'
#if the condtion is true manipulate the string and grab the exact date time and store in varaible and stop the loop to improve the script speed'''
    def get_local_time(self,file_name):         
        with open(file_name,'r', encoding='utf-8',errors='ignore') as _read_content: 
            for line in _read_content:
                if line.startswith('Local time'):
                    _time_value = line.rstrip('\n')
                    self.local_time_value = _time_value[_time_value.index(delimeter)+1:].strip()
                    print(f"***Local_Time: {self.local_time_value}***")
                    break
    def logic(self):        
        obj = []
        count_processed_file = 0
        for file_value in file:
            with open(file_value,'r', encoding='utf-8',errors='ignore') as read_content:
                print(f"***Extrating the valuable output from {pathlib.Path(file_value).stem} file raw data***")
#used the get_local_time function inside in (logic) function as method to get the local time                        
                self.get_local_time(file_value)
                count_processed_file += 1 
                for line in read_content:
                    r = re.findall(r"\d{2}:\d{2}:\d{2}\.\d{3} \[T:\d+\] \{\w+:\d+\} METRIC <log\ssid='[A-Z,a-z,0-9]+'\sexpr='[a-zA-Z0-9!@#*$&()\\-_:`.+,\s]+'\slabel='[A-Z,a-z,0-9]+'\slevel='[0-9]'\s", line)
                    if r:
                        combine_value = self.local_time_value+' '+line
                        obj.append(combine_value) 
        timestr1 = time.strftime("%Y%m%d-%H%M%S") 
        new_file_name = "OutPut-"+timestr1+".log"      
        #opf = open(file_name,"w")
        with open(new_file_name,'w') as opf:
        #for y in obj:
            opf.write(''.join(obj))
            #print("Processing......")
        print("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print(f"1.Valuable data are Extracted and store in new file with the name of {new_file_name}.")
        print(f"2.Number of actual file count from input: {len(file)}")
        print(f"3.Number of Processed file count: {count_processed_file}")
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        print("Process exited with 0")
        #opf.close()
        

def main():
    global file,user_file,delimeter
    delimeter = ':'
    #count_file = 0
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
    obj = etf(file)
    obj.logic()
    
    

if __name__ =='__main__':
    main()
   

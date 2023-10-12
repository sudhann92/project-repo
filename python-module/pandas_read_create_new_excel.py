'''
Install and import the panda library to use for datafram script
import pathlib to used for both windows and linux path
import re library for replace value with regex expression
import datatime module for get the date time values
'''
import pandas as pd
import pathlib 
import re
import datetime
import sys

'''
output_folder_creation is a function for create new folder under in d: 
by using datetime get the current date/month/year for folder name to create in path
used pathlib to convert the windows path as global accessable path
used the if condition to verfied the path or folder available in windows machine or not
if folder not available by using mkdir method created the new folder
'''

def output_folder_creation():
        today_date=datetime.date.today().strftime("%d-%B-%Y")
        cwd = "d:/" #"//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA"
        cwd_1= pathlib.Path(cwd)
        joined_path= cwd_1 / today_date
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)
        return joined_path

def read_excel_file(file_value, filter_column_name, filter_column_value):
    column_name_pic = "PIC"
    data_value = []
#call the folder creation function and store the output in new variable for further use
    output_folder_path = output_folder_creation()  
#Iterate the file and read the content in excel and append the data in new variable in the form of list
    for file_full_path in file_value:        
        try:        
            data_value.append(pd.read_excel(file_full_path))
        except PermissionError as ps:
             print(f'\n----- The {file_full_path} file has opened by some one.kindly close and retrigger the script again------- \n')
             sys.exit(1) 
#Used the pandas concat method to merge the two data value in single dataframe 
    Combine_data_value = pd.concat(data_value, ignore_index=True)
#replace the backslash by using datframe value with particular column      
    Combine_data_value[column_name_pic] = Combine_data_value[column_name_pic].str.replace('\\', '/').fillna('0')
#filter data with Tower column with Apps value        
    tower_apps = Combine_data_value[Combine_data_value[filter_column_name] == filter_column_value ]
#capture the unique value from PIC column      
    unique_values = tower_apps[column_name_pic].unique()
#Use for loop to match with PIC and Apps tower value
    for unique_single_value in unique_values:
#use the regex sub to replace the [\\!&/<>?] value with "_" in PIC value used for excel file name input          
        excel_file_name = re.sub(r"[\\!&/<>?]", "_" , unique_single_value)
        output_path = f"{output_folder_path}\\{excel_file_name}.xlsx"
#used try and except for error handling                 
        try:
#Match the two condition when column PIC == unique PIC value and column 'Tower' should be Apps store the variable in data_value_output      
            data_value_output = Combine_data_value[(Combine_data_value[column_name_pic] == unique_single_value) & (Combine_data_value[filter_column_name] == filter_column_value)] #.str.fullmatch(unique_single_value, na=False)]
#Used to_excel method and saved the output in separate excel sheet                 
            data_value_output.to_excel(output_path, sheet_name=excel_file_name, index=False)
            print("********" + output_path +"Created successfully ********") 
        except Exception as e:
                print('********** Error Exception value********')
                print(e) #
                print(output_path +''+ "PIC name")


column_name = "Tower"
path = input("Enter the Path where sheet located:").strip() # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
path = pathlib.Path(path)
user_file = input("Enter the file name with wildcard to be extracted:").strip()
file = list(path.rglob(user_file))
column_tower_value = str(input("Enter any one option [Apps/DB/Infra/Network/Security]:")).strip()
print('\n--------------------------------------------------------------------------------------------')
print(f"This will create the separate consolidated excel for each PIC under in {column_tower_value} Tower")
print('--------------------------------------------------------------------------------------------\n')

def main():
    
    read_excel_file(file,column_name,column_tower_value)


if __name__ =='__main__':
    main()

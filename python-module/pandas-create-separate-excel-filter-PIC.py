'''
Description:
-----------------------------------------------------------------------------
Vulnerability excel report creation based on Tower column value and removed the duplicates 
------------------------------------------------------------------------------
'''

import sys
import pandas as pd
import pathlib 
import re
import datetime

def output_folder_creation():
        today_date=datetime.date.today().strftime("%d-%B-%Y")
        folder_name = (today_date + '-' + 'PIC')
        cwd = "d:/" #"//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA"
        cwd_1= pathlib.Path(cwd)
        joined_path= cwd_1 / folder_name
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)
        return joined_path


def read_excel_file(file_value, filter_column_name):
    data_value = []
    capture_path = []
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
#find NAN and update new value in the dataframe  
    Combine_data_value[filter_column_name] = Combine_data_value[filter_column_name].str.replace('0', 'No_Name').fillna('No_Name')
    unique_values = Combine_data_value[filter_column_name].unique()
#Use for loop to match with Tower value in Tower column
    for unique_single_value in unique_values:
         if unique_single_value == 0:
              excel_file_name = str(unique_single_value) + '-' + 'PIC'
              output_path = f"{output_folder_path}\\{excel_file_name}.xlsx"
         else: 
            excel_file_name = re.sub(r"[\\!&/<>?]", "_" , unique_single_value)+'-'+'PIC'
            output_path = f"{output_folder_path}\\{excel_file_name}.xlsx"
         try:
#Match the two condition when column PIC == unique PIC value and column 'Tower' should be Apps store the variable in data_value_output      
            data_value_output = Combine_data_value[(Combine_data_value[filter_column_name] == unique_single_value)]
            data_value_output_removed_duplicate = data_value_output.drop_duplicates(subset=['Plugin Name','Severity','IP Address', 'Port'])         
            data_value_output_removed_duplicate.to_excel(output_path, sheet_name=excel_file_name, index=False)
            #print("********" + output_path +"Created successfully ********")
            capture_path.append(output_path)
            #print(output_path)
         except Exception as e:
                print('********** Error Exception value********')
                print(e) #
                print(output_path +' '+ "PIC name")    
    print(capture_path)

column_name = "PIC"
path = input("Enter the Path:").strip() # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
path = pathlib.Path(path)
user_file = input("Enter the file to be extracted:").strip()
file = list(path.rglob(user_file))
print('\n--------------------------------------------------------------------------------------------')
print(f"This will create the separate consolidated excel for each Towers")
print('--------------------------------------------------------------------------------------------\n')
 
def main():
    read_excel_file(file,column_name)

if __name__ == '__main__':
     main()
'''
Description:
-----------------------------------------------------------------------------
Vulnerability excel report creation based on Tower column and filtered with PIC column separately with Pivot Table.
Also removed duplicates values automatically
------------------------------------------------------------------------------

Read the one or more excel(xlsx) file combine the data of that files and create the single excel based upon 'Tower' filter column.
Three input value user need to pass for this script
    1) path of file located example:D:\July-report
    2) Full name of particular file with extension(July_Raw.xlsx) or if you want select all file use wildcard(*) or if you want select particular
    file start with name of 'jul' means use '(jul*)'
    3) Need to pass the 'Tower' column filter value from any one from this ['Apps','DB','Infra','Network','Security']

Below Library Used in this script:

1)Install and import the panda library to use for dataframe script
2)import pathlib to used for both windows and linux path
3)import re library for replace value with regex expression
4)import date time to get the current month and date to create folder
5)import sys system related functions

'''

import pandas as pd
import pathlib 
import re
import datetime
import sys

'''
Examples:

Input values:
--------------
Enter the Path where sheet located:D:\July-report
Enter the file name with wildcard(*) to be extracted:Jul23_Raw.xlsx
Enter any one option [Apps/DB/Infra/Network/Security] case sensitive:DB

Output:
--------------------------------------------------------------------------------------------
This will create the separate consolidated excel for each PIC under in DB Tower
--------------------------------------------------------------------------------------------

overall_app_count: 567
Total_dublicate_values in Apps Tower: 45
After_removed_duplicate_data_value_count: 522


********d:\15-August-2023\example_1.xlsxCreated successfully ********
********d:\15-August-2023\example_2.xlsxCreated successfully ********
********d:\15-August-2023\example_3.xlsxCreated successfully ********
********d:\15-August-2023\example_4.xlsxCreated successfully ********

'''

'''
output_folder_creation is a function for create new folder under in d: 
by using datetime get the current date/month/year for folder name to create in path
used pathlib to convert the windows path as global accessable path
used the if condition to verfied the path or folder available in windows machine or not
if folder not available by using mkdir method created the new folder
'''

def output_folder_creation(column_value):
        today_date=datetime.date.today().strftime("%d-%B-%Y")
        cwd = "d:/" #"//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA"
        cwd_1= pathlib.Path(cwd)
        folder_name = column_value + '_' + today_date
        joined_path= cwd_1 / folder_name
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)
        return joined_path

     

def read_excel_file(file_value, filter_column_name, filter_column_value):
    column_name_pic = "PIC"
    data_value = []

#call the folder creation function and store the output in new variable for further use
    output_folder_path = output_folder_creation(filter_column_value)  

#Iterate the file and read the content in excel and append the data in new variable in the form of list
    for file_full_path in file_value:        
        try:        
            data_value.append(pd.read_excel(file_full_path))
        except PermissionError as ps:
             print(f'\n----- The {file_full_path} file has opened by some one.kindly close and retrigger the script again------- \n')
             sys.exit(1) 

#Used the pandas concat method to merge the two data value in single dataframe 
    Combine_data_value = pd.concat(data_value, ignore_index=True)
#replace the backslash by using datframe value with particular column and fill null/empty column with 'alternate value'      
    Combine_data_value[column_name_pic] = Combine_data_value[column_name_pic].str.replace('\\', '/').fillna('0')
#filter data with Tower column with (input Tower column value[Apps/DB/etc]) value        
    tower_column_value = Combine_data_value[Combine_data_value[filter_column_name] == filter_column_value ]

#used the drop duplicates function to remove the duplicate value from "Plugin Name','Severity','IP Address', 'Port'"

    tower_column_exact_value=tower_column_value.drop_duplicates(subset=['Plugin Name','Severity','IP Address', 'Port'])
    over_all_value_tower_column_value = len(tower_column_value)
    dublicate_data_removed = len(tower_column_exact_value)
    print('-'* 60)
    print(f'overall_app_count: {over_all_value_tower_column_value} \
          \nTotal_dublicate_values in {filter_column_value} Tower: {over_all_value_tower_column_value - dublicate_data_removed} \
          \nAfter_removed_duplicate_data_value_count: {dublicate_data_removed}')
    print('-'* 60)

#capture the unique value from PIC column      
    unique_values = tower_column_exact_value[column_name_pic].unique()

#Use for loop to match with PIC and Apps tower value
    for unique_single_value in unique_values:

#use the regex sub to replace the [\\!&/<>?] value with "_" in PIC value used for excel file name input          
        excel_file_name = re.sub(r"[\\!&/<>?]", "_" , unique_single_value)
        output_path = f"{output_folder_path}\\{excel_file_name}.xlsx"

#used try and except for error handling                 
        try:
#Match the two condition when column PIC == unique PIC value and column 'Tower' should be Apps store the variable in data_value_output      
            data_value_output = Combine_data_value[(Combine_data_value[column_name_pic] == unique_single_value) & (Combine_data_value[filter_column_name] == filter_column_value)] #.str.fullmatch(unique_single_value, na=False)]

 #index used for row value in pivot and for column we used column variable aggfun used to count,sum,mean the column values
 #rename function used to change the column name in pivot table
            pivot_table_value_1 = pd.pivot_table(data=data_value_output,  \
                                        index=['Severity'], aggfunc={'Severity':'count'}).rename(columns={'Severity':'Total_Sev'})
            
#loc funtion is access the rows/columns and Use pandas.Series() to create a sum row at the end of the DataFrame. 
# The index should be set as the same as the specific column you need to sum.

            pivot_table_value_1.loc['Total_Sev']=pd.Series(pivot_table_value_1['Total_Sev'].sum(), index=['Total_Sev'])
            set_rows = len(pivot_table_value_1) + 4

            pivot_table_value_2 = pd.pivot_table(data=data_value_output,  \
                                        index=['IP Address','Plugin Name'], columns=['Port'],aggfunc='size')
            
# pd.Excelwriter method used to wirte multiple sheet in single file
# to_excel function used to write the data in excel sheet
        
            with pd.ExcelWriter(output_path) as writer_value:
                pivot_table_value_1.to_excel(writer_value, sheet_name='VA_Total_value')
                pivot_table_value_2.to_excel(writer_value, sheet_name='VA_Total_value', startrow=set_rows, startcol=3)              
                data_value_output.to_excel(writer_value, sheet_name=excel_file_name, index=False)

            print("********" + output_path +"Created successfully ********") 
        except Exception as e:
                print('********** Error Exception value********')
                print(f'Error occured: {e}') #
                print(output_path +''+ "PIC name")
                sys.exit(1)


def main():
    column_name = "Tower"
    path = input("\nEnter the Path where sheet located:").strip()
    path = pathlib.Path(path)
    user_file = input("\nEnter the file name with wildcard(*) to be extracted:").strip()
    file = list(path.rglob(user_file))
    column_tower_value = str(input("\nEnter any one option [Apps/DB/Infra/Network/Security] case sensitive:")).strip()
    while column_tower_value not in ['Apps','DB','Infra','Network','Security']:
            print('\nPlease enter proper option with case sensitive string\n')
            print('----------------------------------------------------------\n')
            column_tower_value = str(input("Enter any one option [Apps/DB/Infra/Network/Security] case sensitive:")).strip()
    print('-'* 80)
    print(f"This will create the separate consolidated excel for each PIC under in [{column_tower_value}] Tower")
    print('-'* 80)
    read_excel_file(file,column_name,column_tower_value)


if __name__ =='__main__':
    main()

import pandas as pd
from pathlib import Path
import datetime

# today_date=datetime.date.today().strftime("%d-%B-%Y")
# month_value = datetime.date.today().strftime("%e")
# print(month_value)
# print(today_date)

# cwd = "d:/"
# cwd_1= Path(cwd)
# #cwd = Path.home()
# print(cwd_1)
# joined_path= cwd_1 / today_date
# print(joined_path)
# #create_dir = joined_path.mkdir(exist_ok=False)
# if not joined_path.exists():
#     Create_dir = joined_path.mkdir(exist_ok=False)
#     print(f"folder has been created in this path :{joined_path}")
# else:
#     print(f'Folder already in this path {joined_path} created')


def folder_creation():
        today_date=datetime.date.today().strftime("%d-%B-%Y")
        month_value = datetime.date.today().strftime("%e")
        cwd = "d:/" #"//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA"
        cwd_1= Path(cwd)
        #cwd = Path.home()
        #print(cwd_1)
        joined_path= cwd_1 / today_date
        #print(joined_path)
        #create_dir = joined_path.mkdir(exist_ok=False)
        if not joined_path.exists():
            Create_dir = joined_path.mkdir(exist_ok=False)
            #print(f"folder has been created in this path :{joined_path}")
        return joined_path


output = f'{folder_creation()}\\test.xlsx'
print(output)

# def read_excel_file(file_value):
#     #replace_symbols = ['>', '<', ':', '"', '/', '\\', '\|', '\?', '\*']
#     for file_full_path in file_value:
#         data_value = pd.read_excel(file_full_path)
#         column_name_pic = "PIC"
#         column_name_tower = "Tower"
#         tower_apps = data_value[data_value[column_name_tower] == 'Apps' ]
#         unique_value_excel= tower_apps[column_name_pic].str.replace('/', '_').str.replace('\\', '_').unique()
#         unique_values = tower_apps[column_name_pic].unique()
#         print(unique_value_excel)
#         #print(re.sub(r'[\\?;/]', '_', unique_values))
#         #print(tower_apps.head())
#         # for unique_single_value in unique_values:
#         #     data_value_output = data_value[data_value[column_name_pic].str.fullmatch(unique_single_value, na=False)]
#         #     #print(re.sub(r'[\\?;/]', '_',unique_single_value))
#         #     #print(re.sub(r"[\\!&/<>?]", "_", unique_single_value))
#         #     excel_file_name = re.sub(r"[\\!&/<>?]", "_" , unique_single_value)
#         #     #rint(excel_file_name)
#         #     # #(unique_value.replace('/', '_').replace('\\\\', '_')).strip() #regex=True)#.str.strip().str.title()
#         #     output_path = f"{excel_file_name}.xlsx"
#         #     data_value_output.to_excel(output_path, sheet_name=excel_file_name[:31], index=False) 
#         #     print("********" + excel_file_name +".xlsx Created successfully ********") 


# def main():
#     read_excel_file(file)

# path = input("Enter the Path:").strip() # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
# path = pathlib.Path(path)
# user_file = input("Enter the file to be extracted:").strip()
# file = list(path.rglob(user_file))


# if __name__ =='__main__':
#     main()

# # path_value = input("Enter the Path:")
# # File_name= input("Enter the exact file name to split into new excel:")
# # # Define Excel file path
# # excel_file= pathlib.Path(path_value)
# # #excel_file = pathlib.Path(path_value).parent/{0}+".xlsx".format(File_name)
# # data_value = pd.read_excel(excel_file)
# # print(excel_file)

# # from openpyxl import load_workbook
# # wb_obj = load_workbook(filename = 'D:\VA-analysis-2023\Testing-excel.xlsx')
# # sheet_obj = wb_obj.active
# # cell_obj = sheet_obj.cell(row = 1, column = 1)
# # print(sheet_obj.max_column)
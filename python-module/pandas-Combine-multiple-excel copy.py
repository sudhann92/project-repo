import pandas as pd
import pathlib 

#//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA/July-23
path = input("Enter the Path:").strip() # right now path is dynamic and it can be fixed by given path = "xyz/ayx/.."
path = pathlib.Path(path)
user_file = input("Enter the file to be extracted use wildcard(*) to get all file in above path:").strip()
file = list(path.rglob(user_file))
file_name = str(input("Enter the output file_name:" )).strip()
data_value=[]
for file_full_path in file:        
    data_value.append(pd.read_excel(file_full_path))
#Used the pandas concat method to merge the two data value in single dataframe 
Combine_data_value = pd.concat(data_value, ignore_index=True)
Combine_data_value.to_excel(file_name +".xlsx",sheet_name="All_DB_VA",index=False)

import pandas as pd
import re
import datetime
import sys
import math
import pathlib

#file_path_value = "C:\\Users\\P4014297\\Automation-folder\\NTUC-Automation\\01.Network\\test-file.xlsx"
# Load the Excel file
def read_excel_file(file_name):
    for file_path_value in file_name:
        df_file = pd.read_excel(file_path_value)
        df_file_first_two_lines = df_file.head(1).dropna(how ='all', axis=1)
        #df_file_two_lines = df_file_first_two_lines.dropna(how ='all', axis=1)
        print(df_file_first_two_lines)
        #drop the first two coloumns as index value
        df_file = df_file.drop([0, 1])
        #make the third coloumn as 0 index as main title value
        df_file.columns = df_file.iloc[0]
        # drop the second index duplicate value and reset the index value
        df_file = df_file.drop(2).reset_index(drop=True)
        #drop the empty line in the excel
        df_file = df_file.dropna(how='all')


        # Drop 'MIN' columns (if they contain the word "MIN" in the column name)
        df_file = df_file.drop(columns=[col for col in df_file.columns if 'MIN' in col])

        # Function to convert kbps to mbps (if value is in kbps)
        def convert_to_mbps(value):
            if isinstance(value, str) and 'kbps' in value:
                # Extract the numeric part and convert to mbps
                return float(value.replace(' kbps', '')) / 1024
            elif isinstance(value, str) and 'Mbps' in value:
                # Extract the numeric part for Mbps
                return float(value.replace(' Mbps', ''))
            return value

        # # Apply conversion to all relevant columns
        columns_to_convert = ['Circuit utilization (IN) - AVG', 'Circuit utilization (OUT) - AVG',
                            'Circuit utilization (IN) - MAX', 'Circuit utilization (OUT) - MAX']

        for col in columns_to_convert:
            df_file[col] = df_file[col].apply(convert_to_mbps)


        # # Calculate the percentage for all converted mbps columns
        for col in columns_to_convert:
            df_file[f'{col} (%)'] = ((df_file[col] / 300) * 100).round(2)

        actual_value = df_file.drop(columns=[col for col in columns_to_convert])
        # # Write the new data to a new Excel file

        #result = pd.concat([actual_value, First_two_value ], ignore_index=True)
        with pd.ExcelWriter('processed_utilization.xlsx') as writer_value:
               df_file_first_two_lines.to_excel(writer_value,startrow=0, index=False)
               actual_value.to_excel(writer_value,startrow=6, index=False)
              
        # print("Processing complete. The new file is saved as 'processed_utilization.xlsx'.")

def main():
    path = input("\nEnter the Path where sheet located:").strip()
    path = pathlib.Path(path)
    user_file = input("\nEnter the file name with wildcard(*) to be extracted:").strip()
    file = list(path.rglob(user_file))
    #global output_destination_path
    #output_destination_path = str(input("\nEnter the destination folder path to download the new excel file:")).strip()
    print('-'* 80)
    print(f"This will create the separate excel with converted kbps to mbps value")
    print('-'* 80)
    read_excel_file(file)



if __name__ =='__main__':
    main()

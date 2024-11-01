#For this script Python and Pandas,openpyxl,pathlib,datetime,sys required
import pandas as pd
import datetime
import sys
import pathlib

# Function to create the output folder path
def output_folder_creation(path_of_folder):
    today_date = datetime.datetime.today().strftime("%b-%Y")
    __path = pathlib.Path(path_of_folder + '/')
    folder_name = 'Report' + '_' + today_date
    joined_path= __path / folder_name
    try:
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)

    except FileNotFoundError as Fs:
        current_path = pathlib.Path.cwd()
        print("-" * 60)
        print(f'\033[93mThe {path_of_folder} drive not found in your computer.Hence creating folder in current path {current_path} and proceed the script\033[00m')
        print("-" * 60)
        folder_name = 'Report' + '_' + today_date
        joined_path= current_path / folder_name
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)
    return joined_path

# Function to convert kbps to mbps (if value is in kbps)
def convert_kbps_to_mbps(value):
            if isinstance(value, str) and 'kbps' in value:
                # Extract the numeric part and convert to mbps
                return float(value.replace(' kbps', '')) / 1024
            elif isinstance(value, str) and 'Mbps' in value:
                # Extract the numeric part for Mbps
                return float(value.replace(' Mbps', ''))
            return value

def read_excel_file(file_name,path_folder_location):
    #Dynamic file name used the count and store the date time for the file name
    File_count= 0
    date_time = datetime.datetime.today().strftime("%d-%b-%y-%H-%M-%S")
    columns_to_convert = ['Circuit utilization (IN) - AVG', 'Circuit utilization (OUT) - AVG',
                            'Circuit utilization (IN) - MAX', 'Circuit utilization (OUT) - MAX']
     # Write the new data to a new Excel file
    output_folder_path = output_folder_creation(path_folder_location) 
    for file_path_value in file_name:
        File_count += 1 
        df_file = pd.read_excel(file_path_value)
         #grab the first two lines and store in variable for new file creation
        df_file_first_two_lines = df_file.head(1).dropna(how ='all', axis=1)
        #Get the bandwidth value for average calculation
        df_mbps_value = int(df_file_first_two_lines["Bandwidth"].iloc[0].split(" ")[0])
        excel_file_name = f"{File_count}_Circuit_{df_mbps_value}Mbps_percentage_{date_time}.xlsx" 
        #print(df_mbps_value)
        #print(df_file_first_two_lines)
        #drop the first two coloumns as index value
        df_file = df_file.drop([0, 1])
        #make the third coloumn as 0 index as main title value
        df_file.columns = df_file.iloc[0]
        # drop the second index duplicate value and reset the index value and drop the empty line in the rows and columns
        df_file = df_file.drop(2).reset_index(drop=True).dropna(how='all')
        #drop the empty line in the excel
        #df_file = df_file.dropna(how='all')
        # Drop 'MIN' columns (if they contain the word "MIN" in the column name)
        df_file = df_file.drop(columns=[col for col in df_file.columns if 'MIN' in col])
        # Function to convert kbps to mbps (if value is in kbps)
        try:
            for col in columns_to_convert:
                df_file[col] = df_file[col].apply(convert_kbps_to_mbps)
            # # Calculate the percentage for all converted mbps columns
            for col in columns_to_convert:
                df_file[f'{col} (%)'] = ((df_file[col] / df_mbps_value) * 100).round(2)
        except TypeError as Ts:
            print( "-" * 80)
            print(f"The Given file not a proper data \033[91m [{pathlib.Path(file_path_value).name}] \033[00mKindly provide the proper file to proceed it")
            print("-" * 80)
            sys.exit(1)

        #drop the older column value and keep the new column value with percentage
        actual_value = df_file.drop(columns=[col for col in columns_to_convert])
        #calculate the mean or average and Max value in the column
        mean_in_avg = round(actual_value['Circuit utilization (IN) - AVG (%)'].mean(), 4)
        mean_out_avg = round(actual_value['Circuit utilization (OUT) - AVG (%)'].mean(), 4)
        max_in = actual_value['Circuit utilization (IN) - MAX (%)'].max()
        max_out = actual_value['Circuit utilization (OUT) - MAX (%)'].max()
        summary_data = pd.DataFrame({
            'Summary': ['Mean Circuit utilization (IN) - AVG (%)', 'Mean Circuit utilization (OUT) - AVG (%)',
                        'Max Circuit utilization (IN) - MAX (%)', 'Max Circuit utilization (OUT) - MAX (%)'],
            'Values': [mean_in_avg, mean_out_avg, max_in, max_out]
        })
        # # Write the new data to a new Excel file
        #output_folder_path = output_folder_creation(path_folder_location) 
        out_file_name = f"{output_folder_path}\\{excel_file_name}"
        with pd.ExcelWriter(out_file_name) as writer_value:
               df_file_first_two_lines.to_excel(writer_value,startrow=0, index=False)
               actual_value.to_excel(writer_value,startrow=6, index=False)
               summary_data.to_excel(writer_value, startrow=actual_value.shape[0] + 10, index= False)
              
        print(f"************\033[92m Processing completed. The new file is saved as  [{out_file_name}] \033[00m***************")

def main():
    path = input("\nEnter the Path folder where sheet located:").strip()
    path = pathlib.Path(path)
    user_file = input("\nEnter the file name with wildcard(*) to be extracted:").strip()
    output_file = str(input("\nEnter the drive name or path (example c:, d:, e: or c:\\user\\path) to create the new process file: ")).strip()
    file = list(path.rglob(user_file))
    if len(file) == 0:
            print('---------------------------------------------------------------\n')
            print('\nGiven path is empty folder kindly place the proper file and run it again. Exit the script\n')
            print('----------------------------------------------------------\n')
            sys.exit(1)
#    output_destination_path = str(input("\nEnter the destination folder path to download the new excel file:")).strip()
    print('-'* 80)
    print(f"This will create the separate excel with converted kbps to mbps value")
    print('-'* 80)
    read_excel_file(file,output_file)


if __name__ =='__main__':
    main()

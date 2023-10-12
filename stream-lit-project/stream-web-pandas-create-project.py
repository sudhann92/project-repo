import streamlit as st
import sys
import pandas as pd
import pathlib
import re
import datetime,time
import tempfile
import base64
import os, shutil


def output_folder_creation():
        today_date=datetime.date.today().strftime("%d-%B-%Y")
        folder_name = (today_date + '-' + 'PIC')
        cwd = temp_dir #"//10.81.146.52/ITD_Data/Praneeth/005 VA/Sudhan-VA"
        cwd_1= pathlib.Path(cwd)
        joined_path= cwd_1 / folder_name
        if not joined_path.exists():
            joined_path.mkdir(exist_ok=False)
        return joined_path


def download_link(file_path,file_name):
    # Generate a download link for the file
    with open(file_path, "rb") as file:
        file_contents = file.read()
    file_b64 = base64.b64encode(file_contents).decode()
    href = f'<a href="data:file/xlsx;base64,{file_b64}" download="{file_name}.xlsx">Download Processed {file_name} File</a>'
    return href

def delete_old_temp_folder():
    current_time = time.time()
    one_Day_ago = current_time - (60*60)
    one_step_backword = os.path.normpath(str(temp_dir) + os.sep + os.pardir)
#use the listdir function to get the list of files and directories inside that path and did loop for that
    for dir_name in os.listdir(one_step_backword):
#use the path.join function to build the full path of the file and directories
        dir_path = os.path.join(one_step_backword, dir_name)
#use isdir function to check whether the object is directory or  not and used startswith condition to check whether the dir start with 'tmp' name
        if os.path.isdir(dir_path) and dir_name.startswith('tmp'):
            dir_modify_time = os.path.getmtime(dir_path)

            if dir_modify_time < one_Day_ago:
               shutil.rmtree(dir_path)
            #print(f'Deleted {dir_path} which is older than one day')

def read_excel_file(file_value, filter_column_name):
    #st.write("Processing files...")
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
            st.markdown(download_link(output_path, excel_file_name), unsafe_allow_html=True)
            #print(output_path)
         except Exception as e:
                print('********** Error Exception value********')
                print(e) #
                print(output_path +' '+ "PIC name")    
    return capture_path

def stream_web():
    st.title('Kindly upload the Vulnerability consolidated Report')    
    # Create a file uploader
    uploaded_file = st.file_uploader("Choose a file...", type=["csv", "txt", "xlsx"], accept_multiple_files=True)

    if st.button('Process files'):
        try:
            if (uploaded_file is not None) and (len(uploaded_file) > 0):
                global temp_dir
                temp_dir = pathlib.Path(tempfile.TemporaryDirectory().name)
                delete_old_temp_folder()
                file_path=[]
                for upload_new in uploaded_file:
                    temp_file= temp_dir / upload_new.name
                    # Create intermediate directories if they don't exist
                    temp_file.parent.mkdir(parents=True, exist_ok=True)
                    with open(temp_file, "wb") as temp_file_create:
                     temp_file_create.write(upload_new.read())
                    file_path.append(temp_file)
                # temp_dir = tempfile.TemporaryDirectory()
                # #file_path = [os.path.join(temp_dir.name, uploaded_file.name) for upload in uploaded_file]
                # #file = [os.path.join("D:\\RHB-VUL\\", upload.name) for upload in uploaded_file]
                # st.write("You selected:", file_path)
                #delete_old_temp_folder()
                column_name = 'PIC'
                st.write('Processing files......')                
                #destination_path = "\n\n".join(read_excel_file(file_path,column_name))
                read_excel_file(file_path,column_name)
                #st.success(f"{destination_path}: \n\nsuccessfully created the separate PIC files in above destination path")
                st.success("Kindly download the each PIC files", icon="✅")
                #temp_dir.cleanup()

            else:
                st.error('File Not uploaded', icon="🔥")
        except ValueError as value:
            st.error('No File has been uploaded\n\nKindly upload the file and click the process button') 
        #temp_dir.cleanup()

def main():
    stream_web()

if __name__ == "__main__":
    main()

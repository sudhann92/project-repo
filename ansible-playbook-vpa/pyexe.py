import pyexcel as pe
import sys, re
# Load the CSV file
sheet = pe.get_sheet(file_name="testing.csv")

# Specify the column name and the desired value to filter
column_name = 20
desired_value = sys.argv[1]
excel_file=re.sub(r"[\\!&/<>?]", "_" , desired_value)

filtered_data = [sheet.row[0]]
for row in sheet:
    if row[column_name] == desired_value:  # Assuming the column you want to filter is the second column (0-based index)
        filtered_data.append(row)
# Save the filtered data to a new CSV file
pe.save_as(array=filtered_data, dest_file_name=excel_file+"_PIC_file.csv")
print(excel_file+"_value_output_file.csv")

import pandas as pd
import re
import datetime
import sys
import math

file_path_value = "C:\\Users\\P4014297\\Automation-folder\\NTUC-Automation\\01.Network\\test-file.xlsx"
# Load the Excel file
df = pd.read_excel(file_path_value)


#drop the first two coloumns as index value
df = df.drop([0, 1])
#make the third coloumn as 0 index as main title value
df.columns = df.iloc[0]
# drop the second index duplicate value
df = df.drop(2)
#reset the index value
df = df.reset_index(drop=True)
#drop the empty line in the excel
df = df.dropna(how='all')

# Drop 'MIN' columns (if they contain the word "MIN" in the column name)
df = df.drop(columns=[col for col in df.columns if 'MIN' in col])

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
    df[col] = df[col].apply(convert_to_mbps)

# # Calculate the percentage for all converted mbps columns
for col in columns_to_convert:
    df[f'{col} (%)'] = ((df[col] / 300) * 100).round(2)

actual_value = df.drop(columns=[col for col in columns_to_convert])
# # Write the new data to a new Excel file

#result = pd.concat([actual_value, First_two_value ], ignore_index=True)

actual_value.to_excel('processed_utilization.xlsx', index=False)
print("Processing complete. The new file is saved as 'processed_utilization.xlsx'.")

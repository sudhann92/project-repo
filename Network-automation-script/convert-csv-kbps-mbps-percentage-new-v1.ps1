
<#
.SYNOPSIS
    Load the Excel FILE and convert Kbps to Mbps with percentage.

.DESCRIPTION
    This script allows users to load a Excel file containing circuit utilization data.
    script will converted to desired CSV Format and store that file in temp location
    The script will automatically load the convert CSV format file and proceed following actions
    1)	Convert Kbps to Mbps (kbps/1024)
    2)	Calculate the percentage for Mbps (Mbps/Circuit Mbps value * 100)
    3)	Circuit utilization IN AVG - Sum over all rows/Average 
    4)	Circuit utilization OUT AVG – Sum over all rows/ Average
    5)	Circuit utilization IN MAX – Find the max utilization value.
    6)	Circuit utilization OUT MAX - Find the max utilization value.
    After processing, the script will save the modified CSV files to the specified output folder.
.PARAMETER InputFile
    The input CSV file(s) containing circuit utilization data to be processed.

.PARAMETER OutputFolder
    The folder where the processed CSV files will be saved.

.EXAMPLE
     ./convert-kbps-mbps-percentage-csv.ps1
     
     Input = [circuit.xlsx, circuit-2.xlsx, etc.]
     Output = "C:\Reports" or "D:\Processed"

     This will process the provided xlsx file(s), convert the relevant columns, calculate percentages, 
     and save the updated CSV files to the specified output folder.
.OUTPUTS
    CSV files with updated kbps to Mbps convertion and changed to percentage values.

.NOTES
    Version 1.0 
    Production version
#>


try {
    # Select-EXCELFiles Function to prompt for file selection (multiple CSV files)
    #Loaded the .NET assembly system.windows.forms to open the dailog forms to select the file as user friendly
    #Filter property used to filter the appropirate extension format
    function Select-EXCELFiles {
        Add-Type -AssemblyName System.Windows.Forms
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Filter = "Xlsx Files (*.xlsx;*.xls)|*.xlsx;*.xls"
        $OpenFileDialog.Title = "Select CSV Files"
        $OpenFileDialog.Multiselect = $true
        $OpenFileDialog.ShowDialog() | Out-Null
        # If no file has been selected by user this script will get terminated
        if ($OpenFileDialog.FileNames.Count -eq 0){
            Write-Host "`n********* USER NOT SELECTED ANY FILE HENCE STOPPING THE SCRIPT.************`n" -ForegroundColor Red
            exit 
        }
        return $OpenFileDialog.FileNames
    }

        #Get-newoutputfolder Function prompt the window to mention the output destination path
        #Loaded .NET Assembly for input window System.Windows.Forms
    function OutputfolderDailogwindowPrompt{
        Add-Type -AssemblyName System.Windows.Forms
        # Create the form
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Select Output Folder"
        $form.Size = New-Object System.Drawing.Size(1000, 200)  # Set form size (width, height)
        $form.StartPosition = "CenterScreen"

        # Create a label
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Enter the Drive or path (Ex:, C:, D:\foldername) to save the file (or type 'exit' to quit):"
        $label.AutoSize = $true
        $label.Font = New-Object System.Drawing.Font("Arial", 12)  # Set larger font size for the label
        $label.Location = New-Object System.Drawing.Point(10, 20)  # Set label position on form
        $form.Controls.Add($label)

        # Create a text box for input with larger font
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Size = New-Object System.Drawing.Size(900, 30)  # Increase text box size
        $textBox.Location = New-Object System.Drawing.Point(10, 60)  # Set text box position on form
        $textBox.Font = New-Object System.Drawing.Font("Arial", 18)  # Set larger font size for text box
        $textBox.Text = $defaultDrive
        $form.Controls.Add($textBox)

        # Create an OK button
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = "OK"
        $okButton.Location = New-Object System.Drawing.Point(300, 100)  # Set button position on form
        $okButton.Font = New-Object System.Drawing.Font("Arial", 9)
        $okButton.Add_Click({
            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.Close()
        })
        $form.Controls.Add($okButton)

        # Create a Cancel button
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Text = "Cancel"
        $cancelButton.Location = New-Object System.Drawing.Point(400, 100)  # Set button position on form
        $cancelButton.Font = New-Object System.Drawing.Font("Arial", 9)
        $cancelButton.Add_Click({
            $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.Close()
        })
        $form.Controls.Add($cancelButton)

        # Show the form as a dialog
        $form.Topmost = $true
        $dialogResult = $form.ShowDialog()

        return @($dialogResult,$textBox.Text) #array of results to store and returned it

    }

    #Create a new folders based on input. This used for create new folder for store converted excel to CSV as well as create new folder for store
    #the data processed files
    function Get-newoutputfolder {
        param (
            [string]$output_dailogbutton_result, #Get the dailogbutton value
            [string]$name_of_folder, #Get the name of folder from the input
            [string]$path_of_folder, #Get the path the folder should need to create
            [string]$delete_folder = "No" # This variable used to remove the folders 
        )
        #Loaded the .NET assembly microsoft visualbasic for input window

        # Capture the input and process it
        if ($output_dailogbutton_result -eq [System.Windows.Forms.DialogResult]::OK) {
            $output_folder = $path_of_folder
            #Write-Host "`nSelected Output Folder: $output_folder"
            if ($output_folder -eq "exit" -or $output_folder -eq '') {
                    Write-Host "`n********Given Path is empty or user request to Exit the Script.**********`n" -ForegroundColor Red
                    exit  # Exit the script
            }
            #system.io.directory type used to check the give folder path exists in current system or not
            if (-not [System.IO.Directory]::Exists($output_folder)) {
                    Write-Host `n ('-' * 80)
                    Write-Host "The specified path or drive does not exist $output_folder. Using current script path as the default." -ForegroundColor Yellow
                    Write-Host ('-' * 80)
                    $output_folder = Get-Location #This will  get the current path of the location
            }

            # Create a folder with the format Report_MMM-YYYY
            $today_date = Get-Date -Format "MMM-yyyy"
            $folder_name = $name_of_folder + $today_date
            $joined_path = Join-Path -Path $output_folder -ChildPath $folder_name

            #Delete the path if the $delete_folder variable is "yes"
            #test-path is the type used to check whether given path folder is exists or not
            if ((Test-Path -Path $joined_path) -and $delete_folder -eq 'yes') {
                    Write-Host `n ('-' * 80)
                    Write-Host "CSV folder already exsiting deleting the folder and recreating new one." -ForegroundColor Magenta
                    Write-Host ('-' * 80)
                    Remove-Item -Recurse $joined_path
            }

            if (-not (Test-Path -Path $joined_path)) {
                    New-Item -Path $joined_path -ItemType Directory | Out-Null
                    Write-Host `n('-' * 80)
                    Write-Host "Created directory: $joined_path" -ForegroundColor Green
                    Write-Host ('-' * 80)
                } else {
                    Write-Host `n('-' * 80)
                    Write-Host "Directory already exists: $joined_path" -ForegroundColor Yellow
                    Write-Host ('-' * 80)
                }

                return $joined_path
        } else {
            Write-Host "User canceled the input."
            exit
        }
        return $joined_path
    }
    #Convert the excel files to CSV format for a upcoming calculation and data processin
    #Two inputs variables Filenames and output directory path to store the csv files
    function convertExcelTOCSVFiles {
        param (
            [string[]]$excel_file_names,
            [string]$outputDirectory
        )
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $false  # Optional: run Excel in the background
        $csvFiles = @()
        $csv_file_count = 0
        foreach ($file in $excel_file_names) {
            # Full path to the Excel file
            #$excelFilePath = $file.fullname
            $excelFilePath = $file
            #Write-Host $excelFilePath
            # Open the Excel file
            $workbook = $excel.Workbooks.Open($excelFilePath)
            
            # Loop through each worksheet and save as a CSV
            foreach ($sheet in $workbook.Sheets) {
                $csv_file_count += 1
                # Generate the output CSV path using the sheet name and the original Excel file name
                $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
                $sheetName = $sheet.Name
                $outputCsvPath = Join-Path $outputDirectory "$csv_file_count-$fileNameWithoutExtension-$sheetName.csv"

                # Save the worksheet as a CSV
                $sheet.SaveAs($outputCsvPath, 6)  # 6 is the format code for CSV
                Write-Host "Converted sheet '$sheetName' from file '$fileNameWithoutExtension.xlsx' to CSV: $([System.IO.Path]::GetFileNameWithoutExtension($outputCsvPath))"
            }
            $csvFiles += $outputCsvPath
            # Close the workbook
            $workbook.Close($false)
        }

        # Quit Excel
        $excel.Quit()

        # Release COM objects and free up memory
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()

        Write-Host "All Excel files have been converted to CSV."
        return $csvFiles

    }

    #Convert-KbpsToMbps Function used to convert value from kbps to Mbps for each rows and coloumns
    function Convert-KbpsToMbps {
        param ($value)
        if ($value -like "*kbps") {
            #math type and Round method used and type double
            return [math]::Round([double]($value -replace " kbps","") / 1024, 2)
        } elseif ($value -like "*Mbps") {
            return [double]($value -replace " Mbps","")
        }
        else {
                Write-Host `n('-' * 80)
                Write-Host "******NO Kbps AND Mbps VALUE INSIDE $filePath sheet.`n*******KINDLY UPLOAD THE PROPER FILE AND RERUN THE SCRIPT*******" -ForegroundColor Red
                Write-Host `n('-' * 80)
                exit
        }
        return $value
    }

    #Read-CSV file function processing the file data and do calculation and conversions
    #Name of the files and path of the folder
    function Read-CSVFile {
        param (
            [string[]]$fileNames,
            [string]$output_folder_path
        )

        #Initilaize variable to create file with unique name
        $file_count = 0

        Write-Host "`nCSV file is processing......." -ForegroundColor Green
        #Send the files in a loop to process one by one
        foreach ($filePath in $fileNames) {
            
            # Initialize variables to calculate sum and count for averages
            $sumIN_AVG = 0
            $countIN_AVG = 0
            $sumOUT_AVG = 0
            $countOUT_AVG = 0
            
            #Initilize the dynamic file name value by incrementing number and pass to file name 
            $file_count +=1
            $process_file_name = "$file_count"
            #get the content of the data in CSV files
            $fileContent = Get-Content $filePath
            #Load the first two rows content in the separate varaible
            $first_row = $fileContent[0,1]
            #Get the Mbps value for that convert data as csv format 
            $Circuit_Mbps_value = $first_row -replace ",,","," | ConvertFrom-Csv
            #Then access the Bandwidth column and grab the mbps value conver to integer
            $Circuit_mbps_int_value = [int]($Circuit_Mbps_value.Bandwidth -replace "Mbps","")
        
            # Skip the first header row by selecting everything after it
            # This assumes that the second header row is correct and starts with 'Time'
            $cleanedContent = $fileContent | Select-Object -Skip 3
        
            # Write the Exact data content to a temporary file for further processing
            $cleaned_Temp_FilePath_name = $process_file_name + "_cleaned-Temp-file.csv"
            $cleaned_Temp_FilePath_join = Join-Path -Path $output_folder_path -ChildPath $cleaned_Temp_FilePath_name
            #If already temp file avaible it will remove and create a new one
            if (Test-Path -Path $cleaned_Temp_FilePath_join ){
                Remove-Item $cleaned_Temp_FilePath_join
                $cleaned_Temp_FilePath = New-Item -Path $output_folder_path -Name $cleaned_Temp_FilePath_name -ItemType File
                $cleanedContent  | Set-Content -Path $cleaned_Temp_FilePath
            }
            else {
                $cleaned_Temp_FilePath = New-Item -Path $output_folder_path -Name $cleaned_Temp_FilePath_name -ItemType File
                $cleanedContent  | Set-Content -Path $cleaned_Temp_FilePath
            }
            
                    
            # Now import the Exact data CSV (starting from the second header)
            $data = Import-Csv $cleaned_Temp_FilePath
            #Remove the unwanted empty line in rows and coloumns in exact data
            $filteredData = $data | Where-Object {
                ($_.'Time' -ne '0' -and $_.'Time' -ne '' -and $_.'Time' -notmatch 'Generated' ) -or
                ($_.'Circuit utilization (IN) - AVG' -ne '0' -and $_.'Circuit utilization (IN) - AVG' -ne '') -or
                ($_.'Circuit utilization (OUT) - AVG' -ne '0' -and $_.'Circuit utilization (OUT) - AVG' -ne '') -or
                ($_.'Circuit utilization (IN) - MAX' -ne '0' -and $_.'Circuit utilization (IN) - MAX' -ne '') -or
                ($_.'Circuit utilization (OUT) - MAX' -ne '0' -and $_.'Circuit utilization (OUT) - MAX' -ne '')
            }
            
            #Select the particular column for further process calculating
            $finaldata = $filteredData | Select-Object 'Time', 
                                            'Circuit utilization (IN) - AVG', 
                                            'Circuit utilization (OUT) - AVG', 
                                            'Circuit utilization (IN) - MAX', 
                                            'Circuit utilization (OUT) - MAX'
        
            # Process data: Convert kbps to mbps and calculate percentage (Mbps/300 * 100)
            $processedData = $finaldata | ForEach-Object {
                $_.'Circuit utilization (IN) - AVG' = Convert-KbpsToMbps $_.'Circuit utilization (IN) - AVG'
                $_.'Circuit utilization (OUT) - AVG' = Convert-KbpsToMbps $_.'Circuit utilization (OUT) - AVG'
                $_.'Circuit utilization (IN) - MAX' = Convert-KbpsToMbps $_.'Circuit utilization (IN) - MAX'
                $_.'Circuit utilization (OUT) - MAX' = Convert-KbpsToMbps $_.'Circuit utilization (OUT) - MAX'
        
                # Calculate percentage values by dividing Circut Mbps value
                $_.'Circuit utilization (IN) - AVG' = [math]::Round((([double]$_.'Circuit utilization (IN) - AVG') / $Circuit_mbps_int_value) * 100, 2)
                $_.'Circuit utilization (OUT) - AVG' = [math]::Round((([double]$_.'Circuit utilization (OUT) - AVG') / $Circuit_mbps_int_value) * 100, 2)
                $_.'Circuit utilization (IN) - MAX' = [math]::Round((([double]$_.'Circuit utilization (IN) - MAX') / $Circuit_mbps_int_value) * 100, 2)
                $_.'Circuit utilization (OUT) - MAX' = [math]::Round((([double]$_.'Circuit utilization (OUT) - MAX') / $Circuit_mbps_int_value) * 100, 2)
        
                # Sum values for overall average calculation for IN -AG and OUT -AVG Columns
                $sumIN_AVG += [double]$_.'Circuit utilization (IN) - AVG'
                $countIN_AVG++
                $sumOUT_AVG += [double]$_.'Circuit utilization (OUT) - AVG'
                $countOUT_AVG++
        
                $_ #This returns the current modified row (object)
            }
            # Rename the columns to add percentage symbol
            $processedData | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name 'Circuit utilization (IN) - AVG %' -Value $_.'Circuit utilization (IN) - AVG'
                $_ | Add-Member -MemberType NoteProperty -Name 'Circuit utilization (OUT) - AVG %' -Value $_.'Circuit utilization (OUT) - AVG'
                $_ | Add-Member -MemberType NoteProperty -Name 'Circuit utilization (IN) - MAX %' -Value $_.'Circuit utilization (IN) - MAX'
                $_ | Add-Member -MemberType NoteProperty -Name 'Circuit utilization (OUT) - MAX %' -Value $_.'Circuit utilization (OUT) - MAX'
                
                # Remove the old columns
                $_.PSObject.Properties.Remove('Circuit utilization (IN) - AVG')
                $_.PSObject.Properties.Remove('Circuit utilization (OUT) - AVG')
                $_.PSObject.Properties.Remove('Circuit utilization (IN) - MAX')
                $_.PSObject.Properties.Remove('Circuit utilization (OUT) - MAX')

                $_ #This returns the current modified row (object)
            } | Out-Null
        
            # Calculate average for each column after conversion to percentage
            #Measure-Object  find the maximum value of the "Circuit utilization (IN) - MAX" and "Circuit utilization (OUT) - MAX" columns. and select-object to grab the maximum number
            $avgIN_AVG = $sumIN_AVG / $countIN_AVG
            $avgOUT_AVG = $sumOUT_AVG / $countOUT_AVG
            $High_value_IN_MAX = $processedData | Measure-Object -Property 'Circuit utilization (IN) - MAX %' -Maximum | Select-Object -ExpandProperty Maximum 
            $High_value_OUT_MAX = $processedData | Measure-Object -Property 'Circuit utilization (OUT) - MAX %' -Maximum | Select-Object -ExpandProperty Maximum       
        
            # Convert the processed data back to CSV using join-path to combine and create the new file
            $outputFilePath = Join-Path $output_folder_path ($process_file_name + "_Circuit-$Circuit_mbps_int_value-percentage_" + (Get-Date -Format "yy-MMM-dd-HH-mm-ss") + ".csv")
            $processedData | Export-Csv -Path $outputFilePath -NoTypeInformation
        
            #Add the empty line after the processed data
            ""| Add-Content -Path $outputFilePath
            # Add the first row (headers) back to the CSV
            $first_row | Add-Content -Path $outputFilePath
            #Add the first row (headers) back to the CSV
            ""| Add-Content -Path $outputFilePath
            # Write the overall averages at the end of the file
            "Overall Averages %," | Add-Content -Path $outputFilePath
            "Circuit utilization IN AVG, $([math]::Round($avgIN_AVG, 4))" | Add-Content -Path $outputFilePath
            "Circuit utilization OUT AVG, $([math]::Round($avgOUT_AVG, 4))" | Add-Content -Path $outputFilePath
            ""| Add-Content -Path $outputFilePath
            "Maximum Utilization" | Add-Content -Path $outputFilePath
            "Circuit utilization IN MAX, $High_value_IN_MAX" | Add-Content -Path $outputFilePath
            "Circuit utilization OUT MAX, $High_value_OUT_MAX" | Add-Content -Path $outputFilePath 
        
            # Remove the temporary cleaned file
            #Remove-Item $cleaned_Temp_FilePath
            Remove-Temp-folder-files -remove_folder_path $cleaned_Temp_FilePath
            Write-Host `n('-' * 80)
            Write-Host "Processed data saved at $outputFilePath" -ForegroundColor Green
            
        }
        Write-Host ('-' * 80)
    }

    #This function used to remove the file and folders
    #Two inputs remove_folder_path -> Name of the FILE OR FOLDER PATH
    function Remove-Temp-folder-files {
        param (
            [string]$remove_folder_path,
            [string]$recurse = "No"
        )
        if ($recurse -eq "yes") {
            Remove-Item -Recurse $remove_folder_path
            Write-Host `n('-' * 80)
            Write-Host "Deleted the converted Temp CSV files and Folders`n" -ForegroundColor Yellow
        }
        else {
            Remove-Item $remove_folder_path
        }
        
    }


    function Main {
        
        $start_date = Get-Date
        #Get multiple Excel files from the user calling the select-CSVFiles Function 
        $excel_files =  Select-EXCELFiles

        #Call the dailogwindow function prompt to user to eneter the destination folder
        $get_destination_folder_value = OutputfolderDailogwindowPrompt

        #Call the get-newoutputfolder function for create temp folder to store the converted csv files before process
        Write-Host `n('-' * 80)
        Write-Host "CREATE TEMP FOLDER TO STORE CONVERTED CSV FILE" -ForegroundColor Cyan
        $create_csv_store_location_folder = Get-newoutputfolder -output_dailogbutton_result $get_destination_folder_value[0] -name_of_folder "csv_" -path_of_folder $get_destination_folder_value[1] -delete_folder "yes"

        #Call the get-newoutputfolder function for create Report folder to store the actual processed csv files 
        Write-Host "`nCREATE FOLDER TO STORE THE PROCESSED CSV FILE" -ForegroundColor Cyan
        $create_destination_folder_processed = Get-newoutputfolder -output_dailogbutton_result $get_destination_folder_value[0] -name_of_folder "Report_" -path_of_folder $get_destination_folder_value[1]

        #Call the convertExcelTOCSVFiles function to convert the format excel to csv for further process
        Write-Host ('-' * 80)
        Write-Host "CONVERTING EXCEL FILES TO CSV FORMAT" -ForegroundColor Cyan
        Write-Host ('-' * 80)
        $converted_csv_files_value = convertExcelTOCSVFiles -excel_file_names $excel_files -outputDirectory $create_csv_store_location_folder

        #call the Read-CSVFile to read the converted CSV files and processed the data and calculate the desired value
        Read-CSVFile -fileNames $converted_csv_files_value -output_folder_path $create_destination_folder_processed

        #call Remove-Temp-folder-files function to remove the temporary created folders and files during the execution
        Remove-Temp-folder-files -remove_folder_path $create_csv_store_location_folder -recurse "yes"

        $end_date = Get-Date
        $executionTime = $end_date - $start_date
        #Metadata populate the automation effect calculation
        Write-Host "{"
        write-host "`t"Description: Converting the Kbps to Mbps and calculating the Percentage value for all columns","
        Write-Host "`t"Number_Of_Files_Processed:"" ($converted_csv_files_value.count)","
        Write-Host "`t"Total_Script_Execution_Time: $($executionTime.TotalSeconds) seconds","
        Write-Host "`t"Manual_time_efforts_Mins:"" ($converted_csv_files_value.count * 30) "minutes"
        Write-Host "}"
    }

    Main

}
catch {
    Write-Host "Show An error occurred: $($_.Exception.Message)"
}
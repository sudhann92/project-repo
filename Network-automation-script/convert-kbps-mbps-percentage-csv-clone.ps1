
<#
.SYNOPSIS
    Load the CSV and convert Kbps to Mbps with percentage.

.DESCRIPTION
    This script allows users to load a CSV file containing circuit utilization data.
    The script will convert the bandwidth values from Kbps to Mbps for specified columns (In-AVG, In-MAX, Out-AVG, Out-MAX).
    It will also calculate percentages based on the provided formula (value/300 * 100).
    After processing, the script will save the modified CSV files to the specified output folder.

.PARAMETER InputFile
    The input CSV file(s) containing circuit utilization data to be processed.

.PARAMETER OutputFolder
    The folder where the processed CSV files will be saved.

.EXAMPLE
     ./convert-kbps-mbps-percentage-csv.ps1
     
     Input = [circuit.csv, circuit-2.csv, etc.]
     Output = "C:\Reports" or "D:\Processed"

     This will process the provided CSV file(s), convert the relevant columns, calculate percentages, 
     and save the updated CSV files to the specified output folder.

.OUTPUTS
    CSV files with updated kbps to Mbps convertion and changed to percentage values.

.NOTES
    Version 1.0 
    Production version
#>

# Select-CSVFiles Function to prompt for file selection (multiple CSV files)
#Loaded the .NET assembly system.windows.forms

Try {
    # .NET assembly for GUI support
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName Microsoft.VisualBasic
    function Select-CSVFiles {
        #Add-Type -AssemblyName System.Windows.Forms
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Filter = "CSV Files (*.csv)|*.csv"
        $OpenFileDialog.Title = "Select CSV Files"
        $OpenFileDialog.Multiselect = $true
        $OpenFileDialog.ShowDialog() | Out-Null
        if ($OpenFileDialog.FileNames.Count -eq 0){
            #Write-Host "`n********* USER NOT SELECTED ANY FILE HENCE STOPPING THE SCRIPT.************`n" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("No files selected. Exiting script.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            exit 
        }
        return $OpenFileDialog.FileNames
    }



# function Get-newoutputfolder {
#     param (
#         [string]$defaultDrive = "C:"  # Default to C: if no input is provided
#     )
#     #Loaded the .NET assembly microsoft visualbasic for input window
#     Add-Type -AssemblyName Microsoft.VisualBasic

#     while ($true) {
#         # Show input box with instructions
#         $output_folder = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the Drive or path (Ex:, C:, D:\foldername) to save the newly generated file (or type 'exit' to quit)", "Select Output Folder", $defaultDrive)
#         Write-Host $output_folder

#         if ($output_folder -eq "exit" -or $output_folder -eq '') {
#             Write-Host "`n********Given Path is empty or user request to Exit the Script.**********`n" -ForegroundColor Red
#             exit  # Exit the script
#         }

#         if (-not [System.IO.Directory]::Exists($output_folder)) {
#             Write-Host `n ('-' * 80)
#             Write-Host "The specified path or drive does not exist. Using current script path as the default." -ForegroundColor Yellow
#             Write-Host ('-' * 80)
#             $output_folder = Get-Location
#         }

#         # Create a folder with the format Report_MMM-YYYY
#         $today_date = Get-Date -Format "MMM-yyyy"
#         $folder_name = "Report_$today_date"
#         $joined_path = Join-Path -Path $output_folder -ChildPath $folder_name

#         if (-not (Test-Path -Path $joined_path)) {
#             New-Item -Path $joined_path -ItemType Directory | Out-Null
#             Write-Host `n('-' * 80)
#             Write-Host "Created directory: $joined_path" -ForegroundColor Green
#             Write-Host ('-' * 80)
#         } else {
#             Write-Host `n('-' * 80)
#             Write-Host "Directory already exists: $joined_path" -ForegroundColor Yellow
#             Write-Host ('-' * 80)
#         }

#         return $joined_path
#     }
# }

#Get-newoutputfolder Function prompt the window to mention the output destination path
#Loaded >NET Assembly for input window
    function Get-newoutputfolder {
        param (
            [string]$defaultDrive = "C:"  # Default to C: if no input is provided
        )
        #Loaded the .NET assembly microsoft visualbasic for input window
        #Add-Type -AssemblyName System.Windows.Forms

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

        # Capture the input and process it
        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
            $output_folder = $textBox.Text
            Write-Host "Selected Output Folder: $output_folder"
            if ($output_folder -eq "exit" -or $output_folder -eq '') {
                    Write-Host "`n********Given Path is empty or user request to Exit the Script.**********`n" -ForegroundColor Red
                    exit  # Exit the script
            }

            if (-not [System.IO.Directory]::Exists($output_folder)) {
                    Write-Host `n ('-' * 80)
                    Write-Host "The specified path or drive does not exist. Using current script path as the default." -ForegroundColor Yellow
                    Write-Host ('-' * 80)
                    $output_folder = Get-Location
            }

                # Create a folder with the format Report_MMM-YYYY
            $today_date = Get-Date -Format "MMM-yyyy"
            $folder_name = "Report_$today_date"
            $joined_path = Join-Path -Path $output_folder -ChildPath $folder_name

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


#Convert-KbpsToMbps Function used to convert value from kbps to Mbps for each rows and coloumns
    function Convert-KbpsToMbps {
        param ($value)
        if ($value -like "*kbps") {
            return [math]::Round([double]($value -replace " kbps","") / 1024, 2)
        } elseif ($value -like "*Mbps") {
            return [double]($value -replace " Mbps","")
        }
        else {
            Write-Host "`n******NO Kbps AND Mbps Value inside in $filePath sheet.`n*******Kindly upload the proper file and re-run the*******`n" -ForegroundColor Red
            exit
        }
        return $value
    }


#Read-CSV file function processing the file data and do calculation and conversions 
    function Read-CSVFile {
        param (
            [string[]]$fileNames,
            [string]$output_folder_path
        )

        #Initilaize variable to create file with unique name
        $file_count = 0

        Write-Host "`nCSV file is processing......." -ForegroundColor Green
        
        foreach ($filePath in $fileNames) {
            
            # Initialize variables to calculate sum and count for averages
            $sumIN_AVG = 0
            $countIN_AVG = 0
            $sumOUT_AVG = 0
            $countOUT_AVG = 0
            # $sumIN_MAX = 0
            # $countIN_MAX = 0
            # $sumOUT_MAX = 0
            # $countOUT_MAX = 0
            
            #Initilize the dynamic file name value by incrementing number and pass to file name 
            $file_count +=1
            $process_file_name = "$file_count"

            $fileContent = Get-Content $filePath
            #Load the first two rows content in the separate varaible
            $first_row = $fileContent[0,1]

            #Get the Mbps value for that convert data as csv format 
            $Circuit_mbps_value = $first_row -replace ",,","," | ConvertFrom-Csv
            #Then access the Bandwidth column and grab the mbps value conver to integer
            $Circuit_mbps_int_value = [int]($Circuit_mbps_value.Bandwidth -replace "Mbps","")
        
            # Skip the first header row by selecting everything after it
            # This assumes that the second header row is correct and starts with 'Time'
            $cleanedContent = $fileContent | Select-Object -Skip 3
        
            # Write the cleaned content to a temporary file for further processing
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
            
            
        
            # Now import the cleaned CSV (starting from the second header)
            $data = Import-Csv $cleaned_Temp_FilePath
        
            $filteredData = $data | Where-Object {
                ($_.'Time' -ne '0' -and $_.'Time' -ne '' -and $_.'Time' -notmatch 'Generated' ) -or
                ($_.'Circuit utilization (IN) - AVG' -ne '0' -and $_.'Circuit utilization (IN) - AVG' -ne '') -or
                ($_.'Circuit utilization (OUT) - AVG' -ne '0' -and $_.'Circuit utilization (OUT) - AVG' -ne '') -or
                ($_.'Circuit utilization (IN) - MAX' -ne '0' -and $_.'Circuit utilization (IN) - MAX' -ne '') -or
                ($_.'Circuit utilization (OUT) - MAX' -ne '0' -and $_.'Circuit utilization (OUT) - MAX' -ne '')
            }
        
            $finaldata = $filteredData | Select-Object 'Time', 
                                            'Circuit utilization (IN) - AVG', 
                                            'Circuit utilization (OUT) - AVG', 
                                            'Circuit utilization (IN) - MAX', 
                                            'Circuit utilization (OUT) - MAX'
        
            # Process data: Convert kbps to mbps and calculate percentage (Mbps/300 * 100)
            Write-Host $filteredData

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
                # $sumIN_MAX += [double]$_.'Circuit utilization (IN) - MAX'
                # $countIN_MAX++
                # $sumOUT_MAX += [double]$_.'Circuit utilization (OUT) - MAX'
                # $countOUT_MAX++
        
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
            $avgIN_AVG = $sumIN_AVG / $countIN_AVG
            $avgOUT_AVG = $sumOUT_AVG / $countOUT_AVG
            #Measure-Object  find the maximum value of the "Circuit utilization (IN) - MAX" and "Circuit utilization (OUT) - MAX" columns. and select-object to grab the maximum number
            $High_value_IN_MAX = $processedData | Measure-Object -Property 'Circuit utilization (IN) - MAX %' -Maximum | Select-Object -ExpandProperty Maximum 
            $High_value_OUT_MAX = $processedData | Measure-Object -Property 'Circuit utilization (OUT) - MAX %' -Maximum | Select-Object -ExpandProperty Maximum       
            # $avgIN_MAX = $sumIN_MAX / $countIN_MAX
            # $avgOUT_MAX = $sumOUT_MAX / $countOUT_MAX
        
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
            "Circuit utilization IN MAX, $High_value_IN_MAX" | Add-Content -Path $outputFilePath
            "Circuit utilization OUT MAX, $High_value_OUT_MAX" | Add-Content -Path $outputFilePath 
            #$([math]::Round($avgIN_MAX, 4))" 
            # $([math]::Round($avgOUT_MAX, 4))" | Add-Content -Path $outputFilePath
        
            # Remove the temporary cleaned file
            Remove-Item $cleaned_Temp_FilePath
            Write-Host `n('-' * 80)
            Write-Host "Processed data saved at $outputFilePath" -ForegroundColor Green
            
        }
        Write-Host ('-' * 80)
    }


    function Main {

    $start_date = Get-Date
        #Get multiple CSV files from the user calling the select-CSVFiles Function 
    $selectedFiles = Select-CSVFiles
    #$selectedFiles = "C:\Users\P4014297\Automation-folder\NTUC-Automation\01.Network\Test-new.csv"
    #Get output folder input from user , calling the Get-newoutpufolder function
    $outputFolder = Get-newoutputfolder
        #call the function to read the csv file and converted to percentage
        Read-CSVFile -fileNames $selectedFiles -output_folder_path $outputFolder
        $end_date = Get-Date
        $executionTime = $end_date - $start_date
        #Metadata populate the automation effect calculation
        Write-Host "{"
        write-host "`t"Description: Converting the Kbps to Mbps and calculating the Percentage value for all columns","
        Write-Host "`t"Number_Of_Files_Processed:"" ($selectedFiles.count)","
        Write-Host "`t"Total_Script_Execution_Time: $($executionTime.TotalSeconds) seconds","
        Write-Host "`t"Manual_time_efforts_Mins:"" ($selectedFiles.count * 30) "minutes"
        Write-Host "}"
    }

    Main

} Catch {
    Write-Host "Show An error occurred: $($_.Exception.Message)"
}

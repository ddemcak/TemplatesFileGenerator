Write-Host ''
Write-Host -ForegroundColor Yellow '----------------------------------------'
Write-Host -ForegroundColor Yellow '  AXIS Camera Template Reverser v1.00  '
Write-Host -ForegroundColor Yellow '----------------------------------------'
Write-Host ''

# Present parameters.
Write-Host -ForegroundColor Green 'Checking input parameters...'

If ($args.Count -ne 4)
{
    Write-Host -ForegroundColor Red 'Please provide 4 arguments - Input folder, Template, Input CSV file and Delimiter'
    Write-Host ''
    exit
}

# List input parameters.
Write-Host 'Input folder:' $args[0]
Write-Host 'Template:' $args[1]
Write-Host 'Input CSV file:' $args[2]
Write-Host 'Delimiter: ' $args[3]
Write-Host ''

$inputDirectory = $args[0]
$templateFile = $args[1]
$csvFile = $args[2]
$delimiter = $args[3]

# Ask user if he is aware of loosing data in provided files as parameters.
if(Test-Path $csvFile -PathType Leaf) 
{
    Write-Host -ForegroundColor Yellow 'File' $csvFile 'exists. File will be overwritten! Okay (y/n)?'
    $resp = Read-Host
    if($resp -ne 'y')
    {    
        exit
    }
}

if(Test-Path $templateFile -PathType Leaf)
{
    Write-Host -ForegroundColor Yellow 'File' $templateFile 'exists. File will be overwritten! Okay (y/n)?'
    $resp = Read-Host
    if($resp -ne 'y')
    {    
        exit
    }
}


# Reading all *.cmt files from provided folder.
Write-Host -ForegroundColor Green 'Getting files from' $inputDirectory
$files = Get-ChildItem -Path $inputDirectory -Name -Filter "*.cmt" | Sort-Object
Write-Host 'Found' $files.Length 'files.'

# Take 1st file as a reference.
$firstFile = $inputDirectory + "/" + $files[0]

# Calculate number of lines to be analyzed.
$numberOfLines = (Get-Content $firstFile | Measure-Object ).Count
Write-Host 'First file' $firstFile 'has' $numberOfLines 'lines.' 
Write-Host 'Will be taken as reference number of lines.'
Write-Host ''

# Here we store template file content as string
$templateFileContent = ''

# Here we will fill up data for CSV file.
$csvList = New-Object Collections.Generic.List[String]


# Save 1st column with filenames into CSV file.
$csvLine = 'Filename'
$csvList.Add($csvLine)
        
foreach($file in $files)
{
    $csvLine = $file
    $csvList.Add($csvLine)
}

# Load all files into dictionary of arrays.
$allFiles = [ordered]@{}
foreach($file in $files)
{
    $currfile = $inputDirectory + "/" + $file
    $content = (Get-Content $currfile).Split("`n")
    $allFiles.Add($file, $content)
}


# Main loop that goes line by line and compares it with the content of all *.cmt files.
for($i=0; $i -lt $numberOfLines;$i++)
{
    # Let user know how far we are.
    Write-Host -NoNewline "Current line:" $i "`r"
    
    $lineNumber = $i + 1

    $list = New-Object Collections.Generic.List[String]
    $dic = [ordered]@{}
    
    # Make a list of particular lines of all *.cmt file and check if all lines are the same later.
    foreach($file in $files)
    {
        $cntLines = $allFiles[$file]
        $line = $cntLines[$i]
                
        $list.Add($line);
        $dic.Add($file, $line);
    }
    
    # Get out only unique lines.
    $uniques =  $list | Get-Unique
    
    # If we found more than different one line within the all *.cmt files continue here.
    If (@($uniques).length -gt 1) 
    {
        Write-Host -ForegroundColor Green 'On line' $i 'found different values. Listing all data.'

        foreach($key in $dic.Keys)
        {
            Write-Host ${key} "---" $dic[$key]
        }

        # Split the line into parameter name and value
        $paramter, $value = $line.Split("=")
        
        # Save header into CSV property.
        $csvLine = $delimiter + '{'+ $lineNumber + ':' + $paramter.Trim(" ") + 'Value}'
        $csvList[0] += $csvLine
        
        # Save parameters into CSV property for each row (file).
        $idx = 1
        foreach($key in $dic.Keys)
        {
            $prm, $val = $dic[$key].Split("=")

            $csvLine = $delimiter + $val.Trim(" ").Replace("`"","")
            $csvList[$idx] += $csvLine
            $idx++
        }

        # Make paramter general and put into template file.
        $templateParamterValue = $line.Replace($value.Trim(" "), '"{' + $lineNumber + ':' + $paramter.Trim(" ") + "Value" + '}"')
        $templateFileContent +=  $templateParamterValue + "`n"
        
        Write-Host ''
        Write-Host ''

    }
    # All lines are same just put the content into the template file.
    Else
    {        
        # Add line content and NEWLINE at the end if we are not adding last line.
        If($lineNumber -lt $numberOfLines) 
        {
            $templateFileContent += $line + "`n"
        }
        # Last line WITHOUT NEWLINE character.
        ElseIf($lineNumber -eq $numberOfLines) 
        {
            $templateFileContent += $line
        }

    }
}

# Save CSV file.
Write-Host -ForegroundColor Green 'Saving all different parameters to' $csvFile
$csvList | Out-File -FilePath $csvFile

# Save template file file.
Write-Host -ForegroundColor Green 'Saving template file to' $templateFile
$templateFileContent | Out-File -FilePath $templateFile

Write-Host ''
Write-Host -ForegroundColor Green 'Reverser has just finished.'
Write-Host ''

Write-Host ''
Write-Host -ForegroundColor Yellow '----------------------------------------'
Write-Host -ForegroundColor Yellow '  AXIS Camera Template Generator v1.00  '
Write-Host -ForegroundColor Yellow '----------------------------------------'
Write-Host ''

# Present parameters
Write-Host -ForegroundColor Green 'Checking input parameters...'

If ($args.Count -ne 4)
{
    Write-Host -ForegroundColor Red 'Please provide 4 arguments - Output folder, Template, Input CSV file and Delimiter'
    Write-Host ''
    exit
}

Write-Host 'Output folder:' $args[0]
Write-Host 'Template:' $args[1]
Write-Host 'Input CSV file:' $args[2]
Write-Host 'Delimiter:' $args[3]
Write-Host ''

$outputdir = $args[0]
$template = $args[1]
$inputCsvFile = $args[2]
$delimiter = $args[3]


# Verify whether output directory does not exists
if (Test-Path -Path $outputdir) 
{
	Write-Host -ForegroundColor Yellow 'Directort' $outputdir 'exists. All content will be overwritten! Okay (y/n)?'
    $resp = Read-Host
    if($resp -ne 'y')
    {    
        exit
    }
    
}
Else
{
    Write-Host 'Creating' $outputdir 'directory...'
    New-Item -Path $outputdir -ItemType Directory | Out-Null
}


Write-Host ''

Write-Host 'Importing data from file:' $inputCsvFile
$csv = Import-Csv -path $inputCsvFile -Delimiter $delimiter

Write-Host ''

foreach($line in $csv)
{ 
    $properties = $line | Get-Member -MemberType Properties
    
    # First column is dedicated to CMT filenames.
    $column = $properties[0]
    $currentFile = $line | Select -ExpandProperty $column.Name
    
    # Copy template to new file
    Write-Host -ForegroundColor Green 'Copying file from template:' $currentFile'...'
    $currentFile = $outputdir + "/" + $currentFile
	Copy-Item -Path $template -Destination $currentFile
   
    # Replace all {...Value} strings copied from template with values from CSV
    For($i=1; $i -lt $properties.Count;$i++)
    {
        $column = $properties[$i]
        $columnvalue = $line | Select -ExpandProperty $column.Name

        Write-Host -ForegroundColor Gray 'Replacing' $column.Name 'with' $columnvalue 
        (Get-Content -path $currentFile) -replace $column.Name,$columnvalue | Set-Content $currentFile
    }
    
    # Final Check of created file
    If (Select-String -Path $currentFile -Pattern "{" -SimpleMatch -Quiet)
    {
        Write-Host -ForegroundColor Red 'Not all {...Value} string have been replaced!'
    }
    else
    {
        Write-Host -ForegroundColor Green 'File' $currentFile 'has been successfuly created...' 
    }

    Write-Host ''
    Write-Host ''
} 

Write-Host ''
Write-Host -ForegroundColor Green 'Generator has just finished.'
Write-Host ''

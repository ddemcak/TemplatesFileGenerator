# Templates File Generator (and Reverser)
PowerShell scripts for automate templates creation.
When you need to generate a lot of configuration files based on template and some table data modified data, this set of scripts can help to achieve the goal.

## Generator
Generates configuration files from template and CSV data.

This script requires 4 arguments:
* Output directory name
* Template filename
* CSV data filename
* Delimter (usually comma or tab)

### How to use
* Download of pull.
* Prepare template file and use unique strings to identify wich parameters will be replace in each configuration file.
* Prepare CSV table where parameters will have unique names ordered in columns. Each row will represent generated filename in 1st column and value for each parameter from template.
* Edit **runGenerator.bat** and provide proper 4 arguments.
* Run **runGenerator.bat**.
* Chech the results and thank later :-). 

## Reverser
Reconstructs template and CSV data from set of configuration files in a folder.

This script requires 4 arguments:
* Input directory name
* Generated Template filename
* Generated CSV data filename
* Delimter (usually comma or tab)

### How to use
* Download of pull.
* Prepare folder with configuration files that have exatly same content in each line but some parameters differs.
* Edit **runReverser.bat** and provide proper 4 arguments.
* Run **runReverser.bat**.
* Chech the results and thank later :-).


"""
Interactive Active Directory User Query Tool
---------------------------------------------
Prompts for search criteria, builds a PowerShell Get-ADUser query on the fly,
executes it, and exports the results to CSV.

Note: This wraps a short-lived PowerShell script that is written to disk,
executed, and then deleted -- keeping the query logic dynamic without needing
a persistent .ps1 file for every search variation.
"""

import subprocess
import os
import time

enabled_input = input('Do you want to search for enabled or disabled accounts? (Enter "enabled" or "disabled"): ')
username_input = input('Enter the username to search for (use * as wildcard. E.g. "*svc" for usernames ending with "svc"): ')
file_output = input('Enter the name of the CSV file to output (e.g. "output.csv"): ')
server_input = input('Enter the AD server to query (leave blank for default/none, e.g. "dc01.example.local"): ')

enabled_bool = '$True' if enabled_input.lower() == 'enabled' else '$False'

powershell_script = f"""
Get-ADUser -Filter {{(Enabled -eq {enabled_bool}) -and (SamAccountName -like '{username_input}')}}{' -Server ' + server_input if server_input else ''} -Property SamAccountName, Name, EmailAddress, Enabled |
Export-Csv -Path {file_output} -NoTypeInformation
"""

script_path = 'get_AD_users.ps1'

with open(script_path, 'w') as script_file:
    script_file.write(powershell_script)

# Run the PowerShell script and capture the output
completed_process = subprocess.run(['powershell', '-ExecutionPolicy', 'Bypass', '-File', script_path], capture_output=True, text=True, check=True)

# If there are no errors
if not completed_process.stderr:
    print(f'Success! The CSV file was generated at: {os.path.abspath(file_output)}')
else:
    print(f'An error occurred: {completed_process.stderr}')

# Add a delay
time.sleep(1)

# Delete the PowerShell script
os.remove(script_path)

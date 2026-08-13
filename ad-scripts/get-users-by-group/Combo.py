import subprocess

def run_powershell_script(script_path):
    # Define the command to run the PowerShell script
    command = ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path]

    # Run the command
    subprocess.run(command, shell=True)

# Define the paths to your PowerShell scripts
powershell_script_1 = "GRPQuery.ps1"
powershell_script_2 = "PDCQuery.ps1"

# Run the PowerShell scripts
run_powershell_script(powershell_script_1)
run_powershell_script(powershell_script_2)

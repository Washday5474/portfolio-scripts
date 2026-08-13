# Required external dependencies
import os, sys, subprocess
import pandas as pd

# Set the file path for the PowerShell script
# Replace with the path to this script in your own environment
PS_FILE_PATH = "C:\\Scripts\\SSL-TLS-Scans\\PortSpecific\\nmap_scan_PortSpecific.ps1"

def main():
    # Run the PowerShell script that will execute our Nmap scan
    process = subprocess.Popen(["powershell.exe", PS_FILE_PATH], stdout=sys.stdout)
    process.communicate()

    # Store the results of the Nmap scan into a list
    with open("raw_nmap_scan.txt") as input_file:
        input_data = input_file.read().splitlines()

    os.remove("raw_nmap_scan.txt")

    # Create a list to hold our cleaned data
    cleaned_data = []

    # Temp dictionary to hold each individual IP data
    ip_data = {}

    # Parse the list to produce a clean formatted output based on configuration
    for line in input_data:
        if "Nmap scan report for" in line:
            # If ip_data is not empty, append it to cleaned_data
            if ip_data:
                cleaned_data.append(ip_data)

            # Start a new dictionary for the new IP
            ip_data = {"IP": str(line.split("for ", 1)[1])}
        if "/tcp" in line:
            ip_data['Port'] = str(line.split('/', 1)[0])
        if "TLSv" in line:
            tls_version = str(line.split('v', 1)[1].replace(':', '') + " enabled.")
            if 'TLSv' in ip_data:
                ip_data['TLSv'].append(tls_version)
            else:
                ip_data['TLSv'] = [tls_version]
        if "SSLv" in line:
            ssl_version = str(line.split('v', 1)[1].replace(':', '') + " enabled.")
            if 'SSLv' in ip_data:
                ip_data['SSLv'].append(ssl_version)
            else:
                ip_data['SSLv'] = [ssl_version]

    # Don't forget to append the last ip_data
    if ip_data:
        cleaned_data.append(ip_data)

    # Convert our cleaned data into a pandas DataFrame
    df = pd.DataFrame(cleaned_data)

    # Write our DataFrame to an Excel file
    df.to_excel("cleaned_nmap_scan_PortSpecific.xlsx", index=False)

if __name__ == '__main__':
    main()

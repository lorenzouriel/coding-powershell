# Map the administrative share using Administrator credentials
net use \\server.name\C$ /user:User Password

# Copy the backup file to the destination using PowerShell
Copy-Item -Path "C:\Backup\Scripts\*.ps1" -Destination "\\server.name\C$\Scripts" -Force
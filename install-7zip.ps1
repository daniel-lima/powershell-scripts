param([string] $workingDir = $pwd)

$7zaExePath = Join-Path $workingDir '7za.exe'
$7zaZipPath = Join-Path $workingDir '7za920.zip'
if (-Not (Test-Path -LiteralPath $7zaExePath)) {
   if (-Not (Test-Path -LiteralPath $7zaZipPath)) {
      $7zaZipUrl = 'https://www.7-zip.org/a/7za920.zip'
      #if (Get-Command 'Invoke-Webrequest') {
      #   Invoke-WebRequest -Uri "$7zaZipUrl" -OutFile "$7zaZipPath" -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
      #} else {
         $WebClient = New-Object System.Net.WebClient
         $webclient.DownloadFile("$7zaZipUrl", "$7zaZipPath")
      #}
   }

   $shellApp = new-object -com shell.application
   Write-Host "paths $7zaZipPath $workingDir"
   $zipFile = $ShellApp.NameSpace([IO.Path]::GetFullPath($7zaZipPath))
   $targetDir = $ShellApp.NameSpace([IO.Path]::GetFullPath($workingDir))
   foreach ($item in $zipFile.Items()) {
      if ($item.Name -like '7za*') {
         $targetDir.copyHere($item, 16)
      }
   }
}
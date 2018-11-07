param(
   [parameter(Mandatory=$true, Position=0)]
   [string] $workingDir
)

$7zaExePath = Join-Path $workingDir '7za.exe'
$7zaZipPath = Join-Path $workingDir '7za920.zip'
if (-Not (Test-Path -LiteralPath "$7zaExePath")) {
   if (-Not (Test-Path -LiteralPath "$7zaZipPath")) {
      $7zaZipUrl = 'https://www.7-zip.org/a/7za920.zip'
      $WebClient = New-Object System.Net.WebClient
      $webclient.DownloadFile("$7zaZipUrl", "$7zaZipPath")
   }

   $shellApp = new-object -com shell.application
   $zipFile = $ShellApp.NameSpace([IO.Path]::GetFullPath("$7zaZipPath"))
   $targetDir = $ShellApp.NameSpace([IO.Path]::GetFullPath("$workingDir"))
   foreach ($item in $zipFile.Items()) {
      if ($item.Name -eq '7za') {
         $targetDir.copyHere($item, 16)
      }
   }

   Remove-Item -LiteralPath "$7zaZipPath"
}
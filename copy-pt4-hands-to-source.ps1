param(
# Processed hands folder for a particular room
    [parameter(Mandatory=$true)]
    [string] $pt4ProcRoomDir,

# Hand history folder for a particular player at a particular room
    [parameter(Mandatory=$true)]
    [string] $roomHandDir
)

$years = Get-ChildItem -LiteralPath $pt4ProcRoomDir | sort LastWriteTime
foreach ($year in $years) {
   $yearDir = Join-Path $pt4ProcRoomDir $year.Name
   $days = Get-ChildItem -LiteralPath $yearDir | sort LastWriteTime
   foreach ($day in $days) {
       #Write-Host "Processing $day"
       $dayDir = Join-Path $yearDir $day.Name
       $tables = Get-ChildItem -LiteralPath $dayDir | sort LastWriteTime
       foreach ($table in $tables) {
          $srcTable = Join-Path $dayDir $table.Name
          $targetTable = Join-Path $roomHandDir $table.Name
          $srcTableFile = Get-Item -LiteralPath $srcTable
          $copy = $false
          if (Test-Path -LiteralPath $targetTable) {
             $targetTableFile = Get-Item -LiteralPath $targetTable
             if ($srcTableFile.Length -gt $targetTableFile.Length) {
                Remove-Item -LiteralPath $targetTable
                $copy = $True
             }
          } else {
            $copy = $True
          }
          
          if ($copy) {
             Copy-Item $srcTable $targetTable
             #$targetTableFile = Get-Item -LiteralPath $targetTable
             #$targetTableFile.CreationTime = $srcTableFile.CreationTime
             #$targetTableFile.LastAccessTime = $srcTableFile.LastAccessTime
             #$targetTableFile.LastWriteTime = $srcTableFile.LastWriteTime
             #$targetTableFile.Attributes = $srcTableFile.Attributes
             #$targetTableFile.SetAccessControl($srcTableFile.GetAccessControl())
          }
       }
   }
}
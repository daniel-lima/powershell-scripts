param(
# Processed hands folder for a particular room
    [parameter(Mandatory=$true)]
    [string] $pt4ProcRoomDir,

# Hand history folder for a particular player at a particular room
    [parameter(Mandatory=$true)]
    [string] $roomHandDir
)

if (-Not (Test-Path -LiteralPath $pt4ProcRoomDir)) {
   Write-Host "Could not find $pt4ProcRoomDir"
   exit 10
}

if (-Not (Test-Path -LiteralPath $roomHandDir)) {
   Write-Host "Could not find $roomHandDir"
   exit 20
}

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
          $destTable = Join-Path $roomHandDir $table.Name
          $srcTableFile = Get-Item -LiteralPath $srcTable
          $copy = $false
          if (Test-Path -LiteralPath $destTable) {
             $destTableFile = Get-Item -LiteralPath $destTable
             if ($srcTableFile.Length -gt $destTableFile.Length) {
                Remove-Item -LiteralPath $destTable
                $copy = $True
             }
          } else {
            $copy = $True
          }
          
          if ($copy) {
             Copy-Item $srcTable $destTable
          }
       }
   }
}
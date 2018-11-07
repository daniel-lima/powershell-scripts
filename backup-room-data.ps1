param(
   [ValidateSet("PokerStars", "888poker")]
   [string[]] $rooms = @("PokerStars", "888poker"),

   [parameter(Mandatory=$true)]
   [string] $player,

   [string[]] $extraFiles = @(), 

   [Switch] $skipRestorePt4Hands,

   [parameter(Position=0)]
   [string] $destDir = $pwd
)


$userProfile = (get-item env:USERPROFILE).Value -replace '\\', '\\'
$localAppData = (get-item env:LOCALAPPDATA).Value -replace '\\', '\\'
$myDir = Split-Path $MyInvocation.MyCommand.Path

$destDir = $destDir -replace '\\', '\\'


function Run-7Zip() {
   param(
      [parameter(Mandatory=$true, Position=0)]
      [string] $targetZip,

      [parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
      [string[]] $sources
   )

   #Write-Host "sources "$sources.length
   $args = New-Object System.Collections.ArrayList
   for ($i=0; $i -lt $sources.length; $i++) {
     $source = $sources[$i]
     $args.Add("`"$source`"") > $null
   }
   $argsAsStr = $args -Join ' '
   #Write-Host "args = $argsAsStr"

   Invoke-Expression "& '$myDir\install-7zip.ps1' '$pwd'"

   set-alias sz "$pwd\\7za.exe"
   sz a -mx=9 -y "$targetZip" $argsAsStr > $null
}


$timestamp = (Get-Date).tostring('yyyyMMddHHmmss')
foreach ($room in $rooms) {
   switch ($room) {
         'PokerStars' {
            $roomDataDir = "$localAppData\\PokerStars"
         }
         '888poker' {
             $roomDataDir = "$userProfile\\Documents\\888poker"
         }
   }

   if (-Not (Test-Path -LiteralPath $roomDataDir)) {
     Write-Host "Could not find $roomDataDir"
     exit 10
   }

   if (!$skipRestorePt4Hands) {
      $pt4ProcDir = "$localAppData\\PokerTracker 4\\Processed"
      switch ($room) {
         'PokerStars' {
                         $pt4ProcDir = Join-Path $pt4ProcDir 'PokerStars'
                         $roomHandDir = "$roomDataDir\\HandHistory\\$player"
                      }
         '888poker' {
                       $pt4ProcDir = Join-Path $pt4ProcDir '888 Poker'
                       $roomHandDir = "$roomDataDir\\HandHistory\\$player"
                    }
      }

      Invoke-Expression "& '$myDir\copy-pt4-hands-to-source.ps1' -pt4ProcRoomDir '$pt4ProcDir' -roomHandDir '$roomHandDir'" 
   }

   $destZip = "$destDir\\$room.$timestamp.zip"

   #Write-Host "$roomDataDir $destZip"
   Run-7Zip "$destZip" "$roomDataDir"
}

if ($extraFiles.Length -gt 0) {
   foreach ($extraFile in $extraFiles) {
      $files = Get-Item -Path "$extraFile"

      if ($files.Length -lt 1) {
         Write-Host "Could not find $extraFile"
         exit 20
      }   
   }

   $destZip = "$destDir\\extra.$timestamp.zip"
   Run-7Zip "$destZip" -sources $extraFiles
}

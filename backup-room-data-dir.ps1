param(
   [ValidateSet("PokerStars", "888poker")]
   [string[]] $rooms = @("PokerStars", "888poker"),

   [parameter(Mandatory=$true)]
   [string] $player,

   [parameter(Position=0)]
   [string] $destDir = $pwd,

   [Switch] $skipRestorePt4Hands
)


$userProfile = (get-item env:USERPROFILE).Value -replace '\\', '\\'
$localAppData = (get-item env:LOCALAPPDATA).Value -replace '\\', '\\'
$myDir = Split-Path $MyInvocation.MyCommand.Path

$destDir = $destDir -replace '\\', '\\'


function Run-7Zip() {
   param(
      [parameter(Mandatory=$true, Position=0)]
      [string] $srcDir,

      [parameter(Mandatory=$true, Position=1)]
      [string] $targetZip
   )

   Invoke-Expression "& '$myDir\install-7zip.ps1' '$pwd'"

   set-alias sz "$pwd\\7za.exe"
   sz a -mx=9 "$targetZip" "$srcDir"
}


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

   $timestamp = (Get-Date).tostring('yyyyMMddHHmmss')
   $destZip = "$destDir\\$room.$timestamp.zip"

   Write-Host "$roomDataDir $destZip"
   Run-7Zip "$roomDataDir" "$destZip"
}

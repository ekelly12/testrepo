#Param (
#    [Parameter(Mandatory=$true)][string] $shit
#)

#echo $shit

$coreTarget = '/tmp/core'

try {
 . ./script/CaptureCritical/set-env.sh $coreTarget
}
catch {
    Write-Host "Failed: $_"
}

./out/isegfault
./out/ithrowuncaughtex

(Get-ChildItem -Path $coreTarget -Filter "*.core").FullName

$mine = $(ls -l $coreTarget)
Write-Host $mine

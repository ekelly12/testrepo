#Param (
#    [Parameter(Mandatory=$true)][string] $shit
#)

#echo $shit

$coreTarget = '/tmp/core'

try {
 bash ./script2/CaptureCritical/set-env.sh $coreTarget
}
catch {
    Write-Host "Failed: $_"
}
(Get-ChildItem -Path $coreTarget -Filter "*.core").FullName

./out/isegfault

$mine = $(ls -l .)
Write-Host $mine

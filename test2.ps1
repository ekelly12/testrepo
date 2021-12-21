#Param (
#    [Parameter(Mandatory=$true)][string] $shit
#)

#echo $shit

$coreTarget = '/tmp/core'

try {
ulimit -Sc $coreTarget
mkdir -p "$coreTarget"
touch "$coreTarget"/test.core # testing
# sysctl requires sudo
sudo sysctl -w kernel.core_pattern="$coreTarget/%e-%p-%s-%u.core"
}
catch {
    Write-Host $_
}
(Get-ChildItem -Path $coreTarget -Filter "*.core").FullName

$mine = $(ls -l .)
Write-Host $mine

winget install python git.git --disable-interactivity #install Python

$sw = [Diagnostics.Stopwatch]::StartNew() #start timer

python -m pip cache purge #clean up global pip cache
Remove-Item -Recurse -Force $env:LOCALAPPDATA\packages\pythonsoftwarefoundation.python.3.11_qbz5n2kfra8p0\localcache\local-packages\python311\site-packages #clean up local pip cache

python -m pip install --upgrade pip #upgrade pip
python -m pip install pipenv #install pipenv

Remove-Item -Recurse -Force flask #remove old repo
Remove-Item -Recurse -Force Pipfile* #remove old Pipfile
Remove-Item -Recurse -Force pipenvcache #remove old pipcache

md pipenvcache #create new pipcache folder
$env:PIPENV_CACHE_DIR = "$pwd\pipenvcache" #set cache folder for pipenv
$env:PIPENV_VENV_IN_PROJECT=1 #set pipenv to create virtual environment in this folder

git clone https://github.com/pallets/flask #clone repo
Set-Location flask
python -m pipenv install setuptools wheel
python -m pipenv install -r requirements/dev.txt #install flask dependencies
python -m pipenv install $pwd #install flask
python -m pipenv install -r requirements/tests.txt #install test dependencies
Get-ChildItem -Path . -Filter .\tests\*.py | ForEach-Object {python -m pipenv run python $_.FullName} #run tests
Set-Location ..

$sw.Stop() #stop timer

Write-Host $([string]::Format("`n🏁️🏃💨 Total time: {0:d2}:{1:d2}:{2:d2} ⏱️📎🏆️🎉",
                                  $sw.Elapsed.Hours,
                                  $sw.Elapsed.Minutes,
                                  $sw.Elapsed.Seconds)) -ForegroundColor Green

Write-Output $([string]::Format("Total time: {0:d2}:{1:d2}:{2:d2}",
                                  $sw.Elapsed.Hours,
                                  $sw.Elapsed.Minutes,
                                  $sw.Elapsed.Seconds)) | Out-File -FilePath .\flaskbuildtime.txt -Append


# timer script from https://github.com/shanselman/aspnetcore/blob/main/race_build.ps1 
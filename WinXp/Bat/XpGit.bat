@echo off

for /f "tokens=1,2,3 delims=- " %%A in ('date /t') do set sDate=%%A-%%B-%%C
set sTime=%time:~0,2%:%time:~3,2% 
set commit= %sDate%_%time:~0,2%-%time:~3,2%

cd E:\MyWork\MyNote\

C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git init""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A .""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master""

pause
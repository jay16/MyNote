@echo off

for /f "tokens=1,2,3 delims=- " %%A in ('date /t') do set sDate=%%A-%%B-%%C
set commit= %sDate%_%time%

cd E:\MyWork\MyNote\

"D:\Program Files\Git\bin\sh.exe" --login -i -c "E:\\MyWork\\MyNote\\WinXp\\Bat\\GitPush.cmd"
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A ."
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%"
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master"

rem old idea
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git init""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A .""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master""

pause
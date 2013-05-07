@echo off

rem 取得当前日期及时间
for /f "tokens=1,2,3 delims=- " %%A in ('date /t') do set sDate=%%A-%%B-%%C
set commit= %sDate%_%time%

rem 取得当前文件路径 或 set current_dir=%~dp0
set current_dir=%cd%
rem 替换路径中的\为\\,以便引用
set current_str=%current_dir:\=\\%


rem 进入当前文件路径
cd %current_dir%
rem 进入父路径
cd ..
rem 进入祖父路径
cd ..
echo 当前路径：%cd%

rem 使用sh.exe调用git命令
"D:\Program Files\Git\bin\sh.exe" --login -i -c "%current_str%\\GitPush.cmd %commit%"

rem cd E:\MyWork\MyNote\

rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "E:\\MyWork\\MyNote\\WinXp\\Bat\\GitPush.cmd"

rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "E:\\MyWork\\MyNote\\WinXp\\Bat\\GitPush.cmd"


rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git init"
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A ."
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%"
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master"

rem old idea
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git init""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A .""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master""

pause
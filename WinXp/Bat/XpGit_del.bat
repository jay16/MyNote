@echo off

rem ȡ�õ�ǰ���ڼ�ʱ��
for /f "tokens=1,2,3 delims=- " %%A in ('date /t') do set sDate=%%A-%%B-%%C
set commit= %sDate%_%time%

rem ȡ�õ�ǰ�ļ�·�� �� set current_dir=%~dp0
set current_dir=%cd%
rem �滻·���е�\Ϊ\\,�Ա�����
set current_str=%current_dir:\=\\%


rem ���뵱ǰ�ļ�·��
cd %current_dir%
rem ���븸·��
cd ..
rem �����游·��
cd ..
echo ��ǰ·����%cd%

"D:\Program Files\Git\bin\sh.exe" --login -i -c "git init"
"D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A ."
"D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -am %commit%"
"D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master"

pause
rem cd E:\MyWork\MyNote\

rem ʹ��sh.exe����git����
rem "D:\Program Files\Git\bin\sh.exe" --login -i -c "%current_str%\\GitPush.cmd"

rem old idea
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git init""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A .""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m %commit%""
rem C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master""

rem pause
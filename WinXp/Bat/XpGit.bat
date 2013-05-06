@echo off

cd E:\MyWork\MyNote\

C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git init""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git add -A .""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git commit -a -m '2013-05-06'""
C:\WINDOWS\system32\cmd.exe /c ""D:\Program Files\Git\bin\sh.exe" --login -i -c "git push origin master""

pause
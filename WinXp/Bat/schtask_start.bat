@echo off

rem ��ʱ�ϴ�git

schtasks /create /sc minute /mo 30 /tn "XpGIt"   /tr E:\MyWork\MyNote\WinXp\Bat\XpGit.bat

pause
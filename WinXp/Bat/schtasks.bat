@echo off

schtasks /create /sc minute /mo 1 /tn "createFile"   /tr E:\MyWork\MyNote\Windows\newText.cmd

pause
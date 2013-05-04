for /f "tokens=1,2,3 delims=- " %%A in ('date /t') do set sDate=%%A-%%B-%%C
set sTime=%time:~0,2%:%time:~3,2% 
set fileName= %sDate%_%time:~0,2%-%time:~3,2%.text
echo %sDate% %sTime% >> hello.txt
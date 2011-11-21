```
@echo off
if exist %TEMP%\CI (
  echo %%TEMP%%\CI exists - removing %%TEMP%%\CI
  rmdir /s / q %TEMP%\CI
)

schtasks /delete /F /TN post-revs
schtasks /delete /F /TN build-revs
schtasks /delete /F /TN test-revs

echo ############### testing bootstrap
call bootstrap %TEMP%\CI /USER
echo ############### finished bootstrap
if errorlevel 1 echo bootstrap failed! & exit /b 

:: unit tests :-(

svnadmin verify %TEMP%\CI\repo 
if errorlevel 1 (
  set SCRIPTERROR=repo creation failed & goto :testerror 
) else echo repo creation succeeded
if not exist %TEMP%\CI\scripts (
  set SCRIPTERROR=scripts folder creation failed & goto :testerror
) else echo scripts folder OK
if not exist %TEMP%\CI\build-appliance (
  set SCRIPTERROR=build-appliance folder creation failed & goto :testerror
) else echo scripts folder OK
if not exist %TEMP%\CI\test-appliance (
  set SCRIPTERROR=test-appliance folder creation failed & goto :testerror
) else echo test-appliance folder OK

goto :eof

:testerror

echo %SCRIPTERROR%

exit /b 1
```
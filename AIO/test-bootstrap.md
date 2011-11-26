# test-bootstrap.bat

## cleanup
output of the repo and other created structures is under %TEMP%, so clean up any prior runs


```
@echo off
if exist %TEMP%\CI (
  echo %%TEMP%%\CI exists - removing %%TEMP%%\CI
  rmdir /s / q %TEMP%\CI
)
```

## remove any prior created scheduled tasks

```
schtasks /delete /F /TN post-revs
schtasks /delete /F /TN build-revs
schtasks /delete /F /TN test-revs
```

## invoke the bootstrap script

```
echo ############### testing bootstrap
call bootstrap %TEMP%\CI /USER
echo ############### finished bootstrap
if errorlevel 1 echo bootstrap failed! & exit /b 
```

## basic verification

the syntax didn't like my first draft with :-)

```
:: unit tests :-(
```

verify repo; verify folders for scripts, build-appliance, test-appliance

```
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
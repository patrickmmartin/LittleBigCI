# bootstrap.md

# overview 
 
The script places all the artefacts under a root folder;
writes out the script files used by the scheduled tasks and sets up the tasks.
After that point, the build and test workspaces will be updated incrementally upon 
any commit and a standard build command invoked.

Subroutines are used in aid of keeping the main flow readable from the top down.  

# start of script

## parameter validation, or show usage text

```
@echo off
if (%1)==() echo need root folder! & goto :usage
```

addiional optional parameter is whether to turn off the system level switch for the scheduled tasks 
and run tasks under the invoking user account

```
set TASK_SWITCH=/RU SYSTEM
if (%2)==(/USER) set TASK_SWITCH=
```

## create root

```
set SCRIPTERROR=

if not exist %1 (
  echo making root 
  mkdir %1
)
if errorlevel 1 goto :error
```

## create SVN repository

```
echo making repository
svnadmin create %1\repo
if errorlevel 1 goto :error
```

a little bit of syntactic sugar for more legible script programming

```
:: set up a couple of useful variables
set ROOT=%1
:: need to avoid back slashes getting URL encoded so set up a derived variable
set REPOBASE=%1\repo
set REPOURL=%REPOBASE:\=/%

set BUILD_APPLIANCE=%ROOT%\build-appliance
set TEST_APPLIANCE=%ROOT%\test-appliance

set PROJECT_ROOT=%ROOT%\project
set SCRIPT_ROOT=%ROOT%\scripts
```

## create folder for scripts

```
echo making scripts folder
mkdir %SCRIPT_ROOT%
if errorlevel 1 goto :error
```

## create the build appliance folders

```
echo making build appliance folder
mkdir %BUILD_APPLIANCE%
mkdir %BUILD_APPLIANCE%\revs-incoming
mkdir %BUILD_APPLIANCE%\revs-done
mkdir %BUILD_APPLIANCE%\working
mkdir %BUILD_APPLIANCE%\builds
if errorlevel 1 goto :error
```

## create the test appliance folders

```
echo making test appliance folder
mkdir %TEST_APPLIANCE%
mkdir %TEST_APPLIANCE%\revs-incoming
mkdir %TEST_APPLIANCE%\revs-done
mkdir %TEST_APPLIANCE%\working
if errorlevel 1 goto :error
```

## SVN commits to example project, which in due course will appear in the build appliance, then test appliance.

```
echo setting up example project in repository
echo this is the very first commit to this location > scratch.txt
:: no authentication yet
svn mkdir file:///%REPOURL%/project -m"creating project" --username Admin 1>nul
if errorlevel 1 goto :error
svn mkdir file:///%REPOURL%/project/trunk -m"creating trunk" --username Admin 1>nul
if errorlevel 1 goto :error
svn import scratch.txt file:///%REPOURL%/project/trunk/scratch.txt -m"initial revision of scratch.txt" --username Admin 1>nul
if errorlevel 1 goto :error
```

## populate the build appliance

```
echo creating checkout of the project in the build appliance
svn checkout file:///%REPOURL%/project/trunk/ %BUILD_APPLIANCE%\project 1>nul
if errorlevel 1 goto :error
```

## populate the test appliance

```
echo creating checkout of the project in the test appliance
svn checkout file:///%REPOURL%/project/trunk/ %TEST_APPLIANCE%\project 1>nul
if errorlevel 1 goto :error
```

## the post-commit hook is what ties repo commits into the appliancess

```
echo create post-commit hook
echo echo %%2 ^>^> %%1\revs-queue.txt  > %REPOBASE%\hooks\post-commit.bat
if errorlevel 1 goto :error
```

## write out the original scripts

```
call :write-scripts
```

## copy the scripts into place in the root

```
echo create post-revs script
copy post-revs.bat %SCRIPT_ROOT%
if errorlevel 1 goto :error

echo create build-revs script
copy build-revs.bat %SCRIPT_ROOT%
if errorlevel 1 goto :error

echo create test-revs script
copy test-revs.bat %SCRIPT_ROOT%
if errorlevel 1 goto :error
```

## create the scheduled tasks

```
echo create update scheduled task for posting new revisions into the build-appliance
schtasks /Create %TASK_SWITCH% /TN post-revs /SC MINUTE /MO 2 /TR "%SCRIPT_ROOT%\post-revs.bat %REPOBASE% %BUILD_APPLIANCE%"
if errorlevel 1 goto :error

echo create update scheduled task for building new revisions 
schtasks /Create %TASK_SWITCH% /TN build-revs /SC MINUTE /MO 2 /TR "%SCRIPT_ROOT%\build-revs.bat %BUILD_APPLIANCE% %TEST_APPLIANCE%"
if errorlevel 1 goto :error

echo create update scheduled task for testing new revisions 
schtasks /Create %TASK_SWITCH% /TN test-revs /SC MINUTE /MO 2 /TR "%SCRIPT_ROOT%\test-revs.bat %TEST_APPLIANCE%"
if errorlevel 1 goto :error
```

```
echo, OK, we're done!

exit /b %SCRIPTERROR%
```

# script subroutines

## error handling

one very useful special case is handled, else attempt to interpret as a system error
```
:error

set SCRIPTERROR=%errorlevel%

echo.
echo.
echo error with error level %SCRIPTERROR%
echo message:
if %SCRIPTERROR%==9009 (
  echo attempt to invoke missing file
  
) else echo the following may be indicative of the system error message: && net helpmsg %SCRIPTERROR%

exit /b %SCRIPTERROR%
```

## writes the scripts out

```
:write-scripts

call :write-post-revs
call :write-build-revs
call :write-test-revs

goto :eof
```

## post-revs

```
:write-post-revs

echo writing out post-revs...

if exist post-revs.bat del post-revs.bat
>> post-revs.bat echo @echo off
>> post-revs.bat echo ren %%1\revs-queue.txt revs-working.txt 
>> post-revs.bat echo type %%1\revs-working.txt ^>^> %%1\revs-done.txt 
>> post-revs.bat echo for /F %%%%R in (%%1\revs-working.txt) do echo. ^> %%2\revs-incoming\%%%%R 
>> post-revs.bat echo del %%1\revs-working.txt 


goto :eof
```

## build-revs

```
:write-build-revs

echo writing out build-revs...

if exist build-revs.bat del build-revs.bat

>> build-revs.bat echo @echo off
>> build-revs.bat echo setlocal
>> build-revs.bat echo.
>> build-revs.bat echo set BUILDROOT=%%1
>> build-revs.bat echo set TESTROOT=%%2
>> build-revs.bat echo for /F %%%%R in ('dir /b %%BUILDROOT%%\revs-incoming\*') do (
>> build-revs.bat echo   set REV=%%%%R
>> build-revs.bat echo   call :buildrev
>> build-revs.bat echo.  
>> build-revs.bat echo )
>> build-revs.bat echo.
>> build-revs.bat echo @endlocal
>> build-revs.bat echo exit /b
>> build-revs.bat echo.
>> build-revs.bat echo :buildrev
>> build-revs.bat echo.
>> build-revs.bat echo   @echo updating to r%%REV%% ...
>> build-revs.bat echo.  
>> build-revs.bat echo   svn update %%BUILDROOT%%\project -r%%REV%% ^> %%BUILDROOT%%\working\update.log
>> build-revs.bat echo.  
>> build-revs.bat echo   @SET CHANGES=0
>> build-revs.bat echo   @FOR /F "tokens=1" %%%%S in (%%BUILDROOT%%\working\update.log) do @(		
>> build-revs.bat echo 	if "%%%%S"=="U"  SET /A CHANGES += 1
>> build-revs.bat echo 	if "%%%%S"=="A"  SET /A CHANGES += 1
>> build-revs.bat echo 	if "%%%%S"=="M"  SET /A CHANGES += 1
>> build-revs.bat echo 	if "%%%%S"=="C"  SET /A CHANGES += 1
>> build-revs.bat echo 	if "%%%%S"=="D"  SET /A CHANGES += 1
>> build-revs.bat echo   )
>> build-revs.bat echo.
>> build-revs.bat echo   if NOT %%CHANGES%%==0 (
>> build-revs.bat echo     echo update to project - initiating build
>> build-revs.bat echo     mkdir %%BUILDROOT%%\builds\r%%REV%%
>> build-revs.bat echo     echo build made %%DATE%% %%TIME%% ^> %%BUILDROOT%%\builds\r%%REV%%\info.txt	
>> build-revs.bat echo     echo we'll say it worked and add a revision to the test appliance queue ;-^^)
>> build-revs.bat echo     echo here is where we email build success to the project team...
>> build-revs.bat echo     echo. ^> %%TESTROOT%%\revs-incoming\%%REV%%
>> build-revs.bat echo   )
>> build-revs.bat echo   move %%BUILDROOT%%\revs-incoming\%%REV%% %%BUILDROOT%%\revs-done
>> build-revs.bat echo.
>> build-revs.bat echo goto :eof
>> build-revs.bat echo.



goto :eof
```

## test-revs

```
:write-test-revs

echo writing out test-revs...

if exist test-revs.bat del test-revs.bat
>> test-revs.bat echo @echo off
>> test-revs.bat echo setlocal
>> test-revs.bat echo.
>> test-revs.bat echo set TESTROOT=%%1
>> test-revs.bat echo for /F %%%%R in ('dir /b %%TESTROOT%%\revs-incoming\*') do (
>> test-revs.bat echo   set REV=%%%%R
>> test-revs.bat echo   call :testrev
>> test-revs.bat echo.  
>> test-revs.bat echo )
>> test-revs.bat echo.
>> test-revs.bat echo @endlocal
>> test-revs.bat echo exit /b
>> test-revs.bat echo.
>> test-revs.bat echo :testrev
>> test-revs.bat echo.
>> test-revs.bat echo   @echo updating to r%%REV%% ...
>> test-revs.bat echo.  
>> test-revs.bat echo   svn update %%TESTROOT%%\project -r%%REV%%
>> test-revs.bat echo   echo we'll say testing worked too
>> test-revs.bat echo   echo here is where we email test success to the project team...
>> test-revs.bat echo   move %%TESTROOT%%\revs-incoming\%%REV%% %%TESTROOT%%\revs-done
>> test-revs.bat echo.
>> test-revs.bat echo goto :eof
>> test-revs.bat echo.



goto :eof
```

## usage routine for no parameters

```
:usage 
echo usage: %~n0 ROOT
echo script to build working continuuous integration model office 
echo successful result is to
echo [1] create a repository in ROOT\repo
echo [2] create a scripts folder in ROOT\scripts
echo [3] create a build appliance in ROOT\build-machine
echo [4] create a test appliance in ROOT\test-machine
echo [5]  create the required scheduled tasks to implement the CI workflow

exit /b 1
```
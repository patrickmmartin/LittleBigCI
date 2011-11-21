This is _build-revs_

This script is invoked periodically
and will determine whether the targetted checkout has in fact
been updated in any significant manner, based upon the SVN status message.
The reason why this may be useful, as opposed to noting there has been a commit, 
is thatsome projects may be composed of various locations and hence the concatentation 
of the update output is required to know when a build may be needed.


```
@echo off
setlocal

set BUILDROOT=%1
set TESTROOT=%2
for /F %%R in ('dir /b %BUILDROOT%\revs-incoming\*') do (
  set REV=%%R
  call :buildrev
  
)

@endlocal
exit /b
```

```
:buildrev

  @echo updating to r%REV% ...
  
  svn update %BUILDROOT%\project -r%REV% > %BUILDROOT%\working\update.log
  
  @SET CHANGES=0
  @FOR /F "tokens=1" %%S in (%BUILDROOT%\working\update.log) do @(		
	if "%%S"=="U"  SET /A CHANGES += 1
	if "%%S"=="A"  SET /A CHANGES += 1
	if "%%S"=="M"  SET /A CHANGES += 1
	if "%%S"=="C"  SET /A CHANGES += 1
	if "%%S"=="D"  SET /A CHANGES += 1
  )

  if NOT %CHANGES%==0 (
    echo update to project - initiating build
    mkdir %BUILDROOT%\builds\r%REV%
    echo build made %DATE% %TIME% > %BUILDROOT%\builds\r%REV%\info.txt	
    echo we'll say it worked and add a revision to the test appliance queue ;-^)
    echo here is where we email build success to the project team...
    echo. > %TESTROOT%\revs-incoming\%REV%
  )
  move %BUILDROOT%\revs-incoming\%REV% %BUILDROOT%\revs-done

goto :eof
```


This is _test-revs_

The script tests a given revision of the code by ensuring
the test appliance revision is updated to the correct version.
One prerequisite of this is that the test update script should always fetch the 
correct version of the test assets, based upon the update revision.

```
@echo off
setlocal

set TESTROOT=%1
for /F %%R in ('dir /b %TESTROOT%\revs-incoming\*') do (
  set REV=%%R
  call :testrev
  
)

@endlocal
exit /b
```

```:testrev

  @echo updating to r%REV% ...
  
  svn update %TESTROOT%\project -r%REV%
  echo we'll say testing worked too
  echo here is where we email test success to the project team...
  move %TESTROOT%\revs-incoming\%REV% %TESTROOT%\revs-done

goto :eof
```
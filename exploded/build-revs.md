This is _build-revs_

This script is invoked periodically
and will determine whether the targetted checkout has in fact
been updated in any significant manner, based upon the SVN status message.
The reason why this may be useful, as opposed to noting there has been a commit, 
is that some projects may be composed of various locations and hence the concatentation 
of the update output is required to know when a build may be needed.


Fairly standard loop over the dir contents.
A local environment  '''setlocal''' is used to allow scripts to be chained together without accidentally sharing state. 
The dir is assumed to be a set of files named for the appropriate Subversion revision.
Invokes the label _buildrev_ for the revision nos encountered 

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

_buildrev_ does the actual work: the Subversion WC directory _project_ is updated to the passed revision,
and the SVN output parsed for file modifications.
If any modification has occurred, a build output dir is created by SVN revision,
and the build process should be invoked to produce the complete build in that location.
Finally, the incoming revision is moved to the _done_ queue dir - allowing for completion status to be checked, for example.
Note that it is trivial to replay builds by moving the build markers back from revs-done to revs-incoming. 

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


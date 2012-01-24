These is the exploded version: viz. all the files output from bootstrap.bat when it is run.

There is one post-commit hook for the svn repo _post-commit_, and three scripts to be invoked on a periodic basis:
_post-revs_, _build-revs_ and _test-revs_

As part of the bootstrap process, the Windows scheduled tasks are set up for the scheduled scripts.
At this point the CI process is up and running,
barring the formality of having to put in place actual build and test actions into the project.

Simply change the repo in the monitored area, and _something_ will happen in due course.
As a simple tweak, the _post-revs_ task can be directly initiated ahead of schedule.
Tweak upon tweak: at the end of _post-revs_ the _build-revs_ task could be initiated directly also.
This would increase responsiveness, and keep the number of revisions built in one pass to a minimum.

Nota Bene: in this simple demonstrator, the fact the system is up and running hinges upon the file-based access (file:///) to the repo,
obviating the need to set up any process to serve the repo via some other protocol.
On the same machine and same desktop, all of this works smoothly enough, 
although the sharp eyed might note the _post-commit_ command prompt window flashing up for every checkin.

Note: I do not recommend serving an SVN repo via file:///, and especially not over the network.
Issues being: control over the versions of the binary accessing the raw repo data;
need to control a separate layer of permissions to commit to the repo (svn users vs file system users); network performance.



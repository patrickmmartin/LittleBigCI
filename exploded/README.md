These is the exploded version: viz. all the files output from bootstrap.bat when it is run.

There is one post-commit hook for the svn repo _post-commit_, and three scripts to be invoked on a periodic basis:
_post-revs_, _build-revs_ and _test-revs_

As part of the bootstrap process, the Windows scheduled tasks are set up for the scheduled scripts.
At this point the CI process is up and running,
barring the formality of having to put in place actual build and test actions into the project.

Simply change the repo in the monitored area, and _something_ will happen in due course.

Nota Bene: in this simple demonstrator, this hinges upon the file-based access (file:///) to the repo,
obviating the need to set up a process to serve the repo via some other protocol.
On the same machine and same desktop, all of this works smoothly enough, 
although the sharp eyed might note the _post-commit_ command prompt window flashing up for every checkin.

I do not recommend serving an SVN repo via file:///, and especially not over the network.


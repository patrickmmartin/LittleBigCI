These are all the exploded files output from bootstrap.bat.

There is one post-commit hook for the svn repo _post-commit_, and three scripts to be invoked on a periodic basis:
_post-revs_, _build-revs_ and _test-revs_

As part of the bootstrap process, the Windows scheduled tasks are set up for the scheduled scripts,
and the CI process is up and running, barring the formality of having to put in place actual build and test scripts.
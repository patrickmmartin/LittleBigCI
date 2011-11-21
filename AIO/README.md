How to use 

Run test-bootstrap.bat

You will see something like the following output for the first run (on Window 7 Home)

```
############### testing bootstrap
making root
making repository
making scripts folder
making build appliance folder
making test appliance folder
setting up example project in repository
creating checkout of the project in the build appliance
creating checkout of the project in the test appliance
create post-commit hook
writing out post-revs...
writing out build-revs...
writing out test-revs...
create post-revs script
        1 file(s) copied.
create build-revs script
        1 file(s) copied.
create test-revs script
        1 file(s) copied.
create update scheduled task for posting new revisions into the build-appliance
SUCCESS: The scheduled task "post-revs" has successfully been created.
create update scheduled task for building new revisions
SUCCESS: The scheduled task "build-revs" has successfully been created.
create update scheduled task for testing new revisions
SUCCESS: The scheduled task "test-revs" has successfully been created.
 OK, we're done!
############### finished bootstrap
* Verified revision 0.
* Verified revision 1.
* Verified revision 2.
* Verified revision 3.
repo creation succeeded
scripts folder OK
scripts folder OK
test-appliance folder OK


The script can be run multiple times, in which case you will see this:

%TEMP%\CI exists - removing %TEMP%\CI
SUCCESS: The scheduled task "post-revs" was successfully deleted.
SUCCESS: The scheduled task "build-revs" was successfully deleted.
SUCCESS: The scheduled task "test-revs" was successfully deleted.
############### testing bootstrap
making root
making repository
making scripts folder
making build appliance folder
making test appliance folder
setting up example project in repository
creating checkout of the project in the build appliance
creating checkout of the project in the test appliance
create post-commit hook
writing out post-revs...
writing out build-revs...
writing out test-revs...
create post-revs script
        1 file(s) copied.
create build-revs script
        1 file(s) copied.
create test-revs script
        1 file(s) copied.
create update scheduled task for posting new revisions into the build-appliance
SUCCESS: The scheduled task "post-revs" has successfully been created.
create update scheduled task for building new revisions
SUCCESS: The scheduled task "build-revs" has successfully been created.
create update scheduled task for testing new revisions
SUCCESS: The scheduled task "test-revs" has successfully been created.
 OK, we're done!
############### finished bootstrap
* Verified revision 0.
* Verified revision 1.
* Verified revision 2.
* Verified revision 3.
repo creation succeeded
scripts folder OK
scripts folder OK
test-appliance folder OK
```
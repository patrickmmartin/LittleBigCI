This is _post-commit_

This SVN post-commit hook simply appends the revision to the build queue file

```
echo %2 >> %1\revs-queue.txt
```
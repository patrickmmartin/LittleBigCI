@echo off
ren %1\revs-queue.txt revs-working.txt 
type %1\revs-working.txt >> %1\revs-done.txt 
for /F %%R in (%1\revs-working.txt) do echo. > %2\revs-incoming\%%R 
del %1\revs-working.txt 

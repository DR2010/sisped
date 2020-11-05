@echo off
del *.bak
if not exist sisped.cld cld sisped
if     exist sisped.cld cld @sisped.cld sisped

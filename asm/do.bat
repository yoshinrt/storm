@echo off

set path=%path%;C:\cygwin\bin
set BaseDir=d:\dds\storm

goto make_%Ext%

:make_
del *.cnf
del *.dat
del *.dls
del *.lst
del *.list
del *.log
del *.mif
del *.err
del *.cfv
del *.cfv.orig
del *.db?
del *.fit
del *.hex
del *.hif
del *.list
del *.mmf
del *.ndb
del *.pin
del *.pof
del *.rpt
del *.s
del *.sof
del *.snf
del *.ttf
del *_tmp
del STORM.v
del STORM_TEST.v
del save.hist
del storm_uselib.h
goto quit

:make_asm
:make_s
:make_pl
if exist %BaseDir%\STORM_exec.log set aopt=-m
if exist %BaseDir%\STORM_exec.log move %BaseDir%\STORM_exec.log STORM_exec.log > nul

perl %BaseDir%\sgcc\stormas.pl -ot %BaseDir%\text.dat -od %BaseDir%\data.dat -ls %aopt% %1
if ErrorLevel 1 goto quit
perl %BaseDir%\sgcc\stormas.pl -ot %BaseDir%\text.mif -od %BaseDir%\data.mif %1

goto quit

:make_c
set HOME=/home/yoshi
set path=%path%;C:\cygwin\home\yoshi\sgcc
bash -c "make -f %HOME%/sgcc/sgcc %Nde%.mif"

mv *_text.mif ../text.mif
mv *_data.mif ../data.mif

goto quit

:make_bat
:make_v
perl %BaseDir%\bin\vpp.pl STORM_TEST.def.v
perl %BaseDir%\bin\vpp.pl STORM.def.v > nul

goto quit

:quit

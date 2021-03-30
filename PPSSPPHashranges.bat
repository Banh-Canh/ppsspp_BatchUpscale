@echo off
echo working...

set "FOLDERINPUT=D:\Output\TEST\new\"
set "FOLDERREF=D:\Output\TEST\DUMP_BACKUP\"
set "FOLDEROUTPUT=D:\Output\TEST\PROCESSING\DUMP\"
set "TARGETWIDTH=128"
set "TARGETHEIGHT=256"
set "CROP=128x80+0+0"
set "FOLDERFORTXTHASHES=D:\Output\TEST\PROCESSING\DUMP\"

If NOT "%1"=="" set "FOLDERINPUT=%1"
If NOT "%2"=="" set "FOLDERREF=%2"
If NOT "%3"=="" set "FOLDEROUTPUT=%3"
If NOT "%4"=="" set "TARGETWIDTH=%4"
If NOT "%5"=="" set "TARGETHEIGHT=%5"
If NOT "%6"=="" set "CROP=%6"
If NOT "%7"=="" set "FOLDERFORTXTHASHES=%7"

goto :start
:start
setlocal enabledelayedexpansion 
for /r "%FOLDERINPUT%" %%a in (*.png) do (
	set "filenametocompare=%%~na"
	set "clutpattern=!filenametocompare:~8,-8!"
	set "texturehash=!filenametocompare:~16!"
	set "txtaddress=!filenametocompare:~0,-16!" 
	if exist !FOLDERINPUT!\!filenametocompare!.png for /f %%i in ('magick convert !FOLDERINPUT!\%%~na.png -format "%%w" info:') do set width=%%i
	if exist !FOLDERINPUT!\!filenametocompare!.png for /f %%i in ('magick convert !FOLDERINPUT!\%%~na.png -format "%%h" info:') do set height=%%i
	if exist !FOLDERINPUT!\!filenametocompare!.png if !height!==!TARGETHEIGHT! if !width!==!TARGETWIDTH! call :processer
	if !height!==!TARGETHEIGHT! if !width!==!TARGETWIDTH! if exist !FOLDERINPUT!\!filenametocompare!.png XCOPY /Y /Q !FOLDERINPUT!\!filenametocompare!.png !FOLDEROUTPUT!\ > nul && MOVE /y !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\ > nul
)
ENDLOCAL
goto :eof

:processer

setlocal enabledelayedexpansion 
for /r "%FOLDERREF%" %%b in (*!clutpattern!*.png) do (
	if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick convert !FOLDERREF!\%%~nb.png -format "%%w" info:') do set width=%%i
	if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick convert !FOLDERREF!\%%~nb.png -format "%%h" info:') do set height=%%i
	set "diff=1"
	set "disable=NO"
	if !height!==!TARGETHEIGHT! if !width!==!TARGETWIDTH! (
		if exist !FOLDERINPUT!\!filenametocompare!.png if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick convert !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\%%~nb.png -crop 128x256+0+0 +repage miff:- ^| magick compare -metric AE - null: 2^>^&1') do set diff=%%i
		if not !filenametocompare!==%%~nb if NOT !disable!==YES if !diff!==0 (
			if exist !FOLDERINPUT!\!filenametocompare!.png echo 00000000!clutpattern!!texturehash! = %%~nb.png >> !FOLDERFORTXTHASHES!\hashes.txt
			if exist !FOLDERINPUT!\!filenametocompare!.png for /r "%FOLDERINPUT%" %%c in (*!clutpattern!!texturehash!.png) do del !FOLDERINPUT!\%%~nc.png
			set "disable=YES"
		)
		
		if exist !FOLDERINPUT!\!filenametocompare!.png if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick convert !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\%%~nb.png -crop 128x79+0+0 +repage miff:- ^| magick compare -metric AE - null: 2^>^&1') do set diff=%%i
		if NOT !disable!==YES if !diff!==0 (
			if exist !FOLDERINPUT!\!filenametocompare!.png echo 0x!txtaddress!,128,256 = 128,128 >> !FOLDERFORTXTHASHES!\hashranges.txt
			if exist !FOLDERINPUT!\!filenametocompare!.png for /r "%FOLDERINPUT%" %%c in (!txtaddress!*.png) do del !FOLDERINPUT!\%%~nc.png
			set "disable=YES"
		)
	)
)
ENDLOCAL
goto :eof
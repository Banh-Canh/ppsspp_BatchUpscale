@echo off
echo working...

set "FOLDERINPUT=D:\Output\TEST\new\"
set "FOLDERREF=D:\Output\TEST\DUMP_BACKUP\"
set "FOLDEROUTPUT=D:\Output\TEST\PROCESSING\DUMP\"
set "TARGETWIDTH=128"
set "TARGETHEIGHT=256"
set "CROP=128x80+0+0"
:: if crop=ALL then it will check the whole image instead of only the cropped part
set "FOLDERFORTXTHASHES=D:\Output\TEST\PROCESSING\"

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
	set width=999
	set height=999
	:: use of a .bat file to check images dimensions
	IF NOT !TARGETWIDTH!==0 IF NOT !TARGETHEIGHT!==0 if exist !FOLDERINPUT!\!filenametocompare!.png for /f "tokens=2 delims=:" %%i in ('D:\Seafile\Victor\Workshop\GetIMGInfo.bat %%~na.png ^| find /i "Width:"') do set width=%%i
	IF NOT !TARGETWIDTH!==0 IF NOT !TARGETHEIGHT!==0 if exist !FOLDERINPUT!\!filenametocompare!.png for /f "tokens=2 delims=:" %%i in ('D:\Seafile\Victor\Workshop\GetIMGInfo.bat %%~na.png ^| find /i "Height:"') do set height=%%i
	IF NOT !CROP!==ALL if !height!==!TARGETHEIGHT! if !width!==!TARGETWIDTH! call :compareduplicatepreset1
	IF %CROP%==ALL call :compareduplicate
	IF NOT %CROP%==ALL if !height!==!TARGETHEIGHT! if !width!==!TARGETWIDTH! XCOPY /Y /Q !FOLDERINPUT!\!filenametocompare!.png !FOLDEROUTPUT!\ > nul && MOVE /y !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\ > nul
	IF %CROP%==ALL if exist !FOLDERINPUT!\!filenametocompare!.png XCOPY /Y /Q !FOLDERINPUT!\!filenametocompare!.png !FOLDEROUTPUT!\ > nul && MOVE /y !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\ > nul
)
ENDLOCAL
goto :eof

:compareduplicatepreset1
setlocal enabledelayedexpansion 
set "clutpattern=!filenametocompare:~8,-8!"
set "texturehash=!filenametocompare:~16!"
set "txtaddress=!filenametocompare:~0,-16!" 
for /r "%FOLDERREF%" %%b in (*!clutpattern!*.png) do (
	set "diff=1"
	if exist !FOLDERINPUT!\!filenametocompare!.png if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick convert !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\%%~nb.png -crop !CROP! +repage miff:- ^| magick compare -metric AE - null: 2^>^&1') do set diff=%%i
	if not !filenametocompare!==%%~nb if !diff!==0 (
		if exist !FOLDERINPUT!\!filenametocompare!.png echo 00000000!clutpattern!!texturehash! = %%~nb.png >> !FOLDERFORTXTHASHES!\hashes.txt
		if exist !FOLDERINPUT!\!filenametocompare!.png for /r "%FOLDERINPUT%" %%c in (*!clutpattern!!texturehash!.png) do del !FOLDERINPUT!\%%~nc.png
	)
)
ENDLOCAL
goto :eof

:compareduplicate
setlocal enabledelayedexpansion 
set "clutpattern=!filenametocompare:~8,-8!"
set "texturehash=!filenametocompare:~16!"
set "txtaddress=!filenametocompare:~0,-16!" 
for /r "%FOLDERREF%" %%b in (*!clutpattern!*.png) do (
	set "diff=1"
	if exist !FOLDERINPUT!\!filenametocompare!.png if exist !FOLDERREF!\%%~nb.png for /f %%i in ('magick compare -metric AE !FOLDERINPUT!\!filenametocompare!.png !FOLDERREF!\%%~nb.png null: 2^>^&1') do set diff=%%i
	if not !filenametocompare!==%%~nb if !diff!==0 (
		echo deleting duplicate and adding to hashes.txt..
		if exist !FOLDERINPUT!\!filenametocompare!.png echo 00000000!clutpattern!!texturehash! = %%~nb.png >> !FOLDERFORTXTHASHES!\hashes.txt
		if exist !FOLDERINPUT!\!filenametocompare!.png for /r "%FOLDERINPUT%" %%c in (*!clutpattern!!texturehash!.png) do del !FOLDERINPUT!\%%~nc.png
	)
)
ENDLOCAL
goto :eof

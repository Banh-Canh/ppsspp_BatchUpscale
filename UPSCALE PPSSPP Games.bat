@echo off
mode con:cols=160 lines=40
::::::::::::::::::::::::::::::::::::::: CONFIGURATION START ::::::::::::::::::::::::::::::::::::::::::::

:: What main "upscaler" do you want to use ? ONLY ESRGAN IS SUPPORTED FOR NOW
set "MODE=ESRGAN"

:: PATH to ESRGAN python script
set "ESRGANPATH=D:\Programmes\ESRGAN\upscale.py"

:: PATH to ESRGAN Folder
set "ESRGANFOLDERPATH=D:\Programmes\ESRGAN\"

:: PATH to waifu2x-caffe-cui.exe
set "WAIFUCAFFECUIPATH=D:\Programmes\waifu2x-caffe\waifu2x-caffe-cui.exe"

:: PATH to waifu2x vulkan exe
set "WAIFUVULKANCUIPATH=D:\Programmes\waifu2x-ncnn-vulkan-20200818-windows\waifu2x-ncnn-vulkan.exe"

:: PATH to all of my PPSSPP related scripts, only PPSSPPDuplicateProcess.bat is actually used for now.
set "SCRIPTSPATH=D:\Output"

:::::::::::::::::: ESRGAN MODE ::::::::::::::::::::::::::::::::::::::::::::::::

:: PATH to ESRGAN Model to use, chain model separated by ^>
::set "ESRGANMODEL=1x_BC1_take2_260850_1x_artifacts_dithering_alsa_interp_075.pth^>4x_NMKD-Yandere2_255000_G_4x_NMKD-UltraYandere_300k_interp_08.pth"
set "ESRGANMODEL=1x_BC1_take2_260850_1x_artifacts_dithering_alsa_interp_075.pth^>4x_NMKD-Yandere2_255000_G_4x_NMKD-YandereNeoXL_200k_interp_08.pth"

:: Additionnal ESRGAN arguments to apply
set "ESRGANARG=--skip_existing --alpha_mode 2"

::PATH to OUTPUT Folder, where texture (and upscaled textures) will be stored then copied to PPSSPP texture replacement folder.
set "OUTPUTFOLDER=D:\OUTPUT"

::PATH to PPSSPP "memstick" folder
set "MEMSTICKFOLDER=D:\Emulation\PPSSPP\memstick"

:: Re-upscale everything based on backup ?
set "REDOFULL=YES"

:: Apply fix for edge for sprite using spritefix by Dinjerr
set "SPRITEFIX=YES"
set "SPRITEFIXFOLDER=D:\Programmes\spritefix-master"

:: Lossy Optimize 
set "OPTIMIZE=YES"
set "PNGQUANTPATH=D:\Programmes\pngquant\pngquant.exe"

:: Upscale alpha channel separately ? ESRGAN ONLY
set "SPLIT=NO"

:: Upscale x2 then downscale back to 1.0 with waifucaffe, it seems it reduce edge artifact, seems to make things worse if SPRITEFIX is also enabled ? ESRGAN ONLY
set "PRECAFFE=NO" 

:: ALPHAFIX enabled, alpha channel fix will be applied (attempt to counter ESRGAN changing color of the alpha channel. Use imagemagick to change color near black or white to black or white.
:: IF SPLIT=YES this is applied on the alpha channel only
set "ALPHAFIX=YES"
set "fuzzblack=10%%"
set "fuzzwhite=30%%"
:: fuzz white only supported if SPLIT=YES, won't do anything if SPLIT is not YES

::::::::::::::::::::::::::::::::::::::: CONFIGURATION END ::::::::::::::::::::::::::::::::::::::::::::

cd /d %ESRGANFOLDERPATH%

IF EXIST ESRGANMODELVAR.tmp del ESRGANMODELVAR.tmp > nul
echo %ESRGANMODEL% > %ESRGANFOLDERPATH%\ESRGANMODELVAR.tmp 
set /p ESRGANMODELARG= < %ESRGANFOLDERPATH%\ESRGANMODELVAR.tmp
IF EXIST ESRGANMODELVAR.tmp del ESRGANMODELVAR.tmp > nul

:: Argument support, bypass prompt *.bat %GAME%
If NOT "%1"=="" set "GAME=%1" && goto :checksupport 

:choosegame

cls
:::::: Just a reminder of what game is supported and what is the "correct answer" for each to trigger the script  (don't really need to edit this part :::

echo.
echo Little script to upscale PPSSPP games texture dump. Require to configure by editing the top of this bat file. 
echo.
echo /\ Mode %MODE% /\ & echo. & echo. ARG: %ESRGANARG% & echo. MODEL: %ESRGANMODEL% & echo.
If %REDOFULL%==YES echo /\ REDOFULL enabled, all textures from the chosen game's backup will be upscaled and installed /\
IF %MODE%==ESRGAN goto :warningesrgan
:warningesrgan
If %SPRITEFIX%==YES echo /\ SPRITEFIX enabled, spritefix by Dinjerr will be applied /\
If %PRECAFFE%==YES echo /\ PRECAFFE enabled, textures will be upscaled x2 then downscaled back to x1 with waifu2xcaffe before the upscaling start /\
If %SPLIT%==YES echo /\ SPLIT enabled, alpha channel will be upscaled separately /\
IF %ALPHAFIX%==YES echo /\ ALPHAFIX enabled, alpha channel fix will be applied (attempt to counter ESRGAN changing color of the alpha channel) /\
IF %ALPHAFIX%==YES echo 	-- black fuzz : %fuzzblack% 
If %SPLIT%==YES IF %ALPHAFIX%==YES echo 	-- white fuzz : %fuzzwhite% 
goto :endwarning
:endwarning
echo.
echo Supported games:
echo.
echo [DAOD] ULES00999 Disgaea 1 Afternoon of Darkness(EUR)
echo [DDHD] ULES01392 Disgaea 2 Dark Hero Days (EUR)
echo [P2IS] ULES01557 Persona 2 Innocent Sin (EU)
echo [P2EP] NPJH50581 Persona 2 Eternal Punishment (JAP)
echo [P3P] ULES01523 Persona 3 Portable (EU)
echo [GWOT] NPEH00137 Growlanser Wayfarer of Time (EU)
echo [TITS] ULES01556 The Legend of Heroes Trails in the Sky (EU)
echo [TITS21] NPEH00166 The Legend of Heroes Trails in the Sky SC1 (EU)
echo [TITS22] NPEH00167 The Legend of Heroes Trails in the Sky SC2 (EU)
echo.
echo [nothing] to exit

:::::

set "GAME="
echo.

:::::: ASK what game dump is going to be upscaled :::::::::

set /p "GAME=What PPSSPP game to upscale (case sensitive)? "
echo.

:::::::::::::::: EDIT the conditions below to add support for more games :::::::::::::::::::::::::::
::::::::: ADD SUPPORT FOR GAME HERE, GAME variable is the FOLDER where upscaled textures and the backup will be stored (ADD a IF condition to what you want the folder to be named::::
:::::::::::::::::::::: ID VARIABLE is the name of the folder where the texture dump from PPSSPP is ::::::::::::::::::::::::::::::::::::::::::::

:checksupport
If %GAME%==P3P (SET "ID=ULES01523" && goto :checkfolders)
If %GAME%==P2IS (SET "ID=ULES01557" && goto :checkfolders)
If %GAME%==P2EP (SET "ID=NPJH50581" && goto :checkfolders)
If %GAME%==DAOD (SET "ID=ULES00999" && goto :checkfolders)
If %GAME%==DDHD (SET "ID=ULES01392" && goto :checkfolders)
If %GAME%==GWOT (SET "ID=NPEH00137" && goto :checkfolders)
If %GAME%==TITS (SET "ID=ULES01556" && goto :checkfolders)
If %GAME%==TITS21 (SET "ID=NPEH00166" && goto :checkfolders)
If %GAME%==TITS22 (SET "ID=NPEH00167" && goto :checkfolders)

If %GAME%==TEST (SET "ID=TEST" && set "REDOFULL=YES" && goto :checkfolders)
echo Game not implemented yet.
goto :choosegame

:checkfolders

set "stepcreatefolders=working..."
set "stepmovedump=working..."
set "stepredodump=working..."
set "stepspritefix=working..."
set "stepprecaffe=working..."
set "stepsplitchannels=working..."
set "stepupscaleesrgan=working..."
set "stepupscaleesrgansplit=working..."
set "stepmergechannels=working..."
set "stepinstalltextures=working..."
call :progress
if not %GAME%==TEST if not exist %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new md %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new
if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP md %OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP
if not exist %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP md %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP
if not exist %OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP md %OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP
if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED md %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED

if %ERRORLEVEL% == 0 set "stepcreatefolders=done" && goto :movetextdump
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :unsuccessfulexit

:movetextdump
call :progress

:: filter duplicate images using imagemagick and add the hashes to the textures.ini, see related .bat for infos on the arguments.
If NOT %GAME%==TEST (

	call %SCRIPTSPATH%\PPSSPPDuplicateProcess.bat %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new\ %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\ %OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\ 0 0 ALL %OUTPUTFOLDER%\%GAME%\PROCESSING\

	echo. >> %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\hashes.txt
	type %OUTPUTFOLDER%\%GAME%\PROCESSING\hashes.txt >> %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\hashes.txt

	type %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures_template.txt > %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures.ini
	echo. >> %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures.ini
	echo. >> %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures.ini
	echo [hashes] >> %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures.ini
	type %OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\hashes.txt >> %MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\textures.ini

)

::IF EXIST "%MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new\*.png" XCOPY /D /Y /Q "%MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new\*.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\*.png" 

if %ERRORLEVEL% == 0 set "stepmovedump=done" && goto :REDOFULL
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :unsuccessfulexit

:REDOFULL

call :progress
:: redo/upscale everything from backup if enabled
If %REDOFULL%==YES IF EXIST "%OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\*" XCOPY /D /S /Y /Q "%OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\*.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP" > nul

goto :skipped
echo 	--checking for textures 8x8 and lower to ignore...
	setlocal enabledelayedexpansion 
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\" %%a in (*.png) do (
		for /f %%i in ('magick convert !OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png -format "%%w" info:') do set width=%%i
		for /f %%i in ('magick convert !OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png -format "%%h" info:') do set height=%%i
		if !width! LSS 8 if exist "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" XCOPY /Y /Q /D "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" "!OUTPUTFOLDER!\!GAME!\PROCESSING\UPSCALED\%%~na.png" > nul
		if !height! LSS 8 if exist "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" XCOPY /Y /Q /D "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" "!OUTPUTFOLDER!\!GAME!\PROCESSING\UPSCALED\%%~na.png" > nul
		if !width! LSS 8 if exist "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" del /q !OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png > nul
		if !height! LSS 8 if exist "!OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png" del /q !OUTPUTFOLDER!\!GAME!\PROCESSING\DUMP\%%~na.png > nul
	)
	ENDLOCAL
:skipped
IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\*.png" XCOPY /Y /Q /D "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\*.png" "%OUTPUTFOLDER%\%GAME%\DUMP_BACKUP\" > nul
IF %MODE%==ESRGAN if %ERRORLEVEL% == 0 set "stepredodump=done" && goto :ESRGAN
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :unsuccessfulexit

:::::::::::::::::::::::::::::::::::::::::: ESRGAN MODE START :::::::::::::::::::::::::::::::::::::::::::::::::::::::

	:ESRGAN
	IF NOT %SPRITEFIX%==YES goto :nospritefix
	set TOSPRITEFIX=0
	set SPRITEFIXDONE=0
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\" %%a in (*.png) do set /a TOSPRITEFIX+=1
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPFIXED\" %%a in (*.png) do set /a SPRITEFIXDONE+=1
	IF %TOSPRITEFIX%==%SPRITEFIXDONE% set "DUMP=DUMPFIXED" && set "stepspritefix=done" && goto :PRECAFFE
	:spritefix
	call :progress
	set "DUMP=DUMPFIXED"
	DEL /f /q "%SPRITEFIXFOLDER%\input\*"
	DEL /f /q "%SPRITEFIXFOLDER%\output\*"
	XCOPY /Q /Y "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\*.png" "D:\Programmes\spritefix-master\input\" > nul
	cd /d "%SPRITEFIXFOLDER%\"
	python "%SPRITEFIXFOLDER%\spritefix.py" > nul
	if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP% md %OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%
	XCOPY /Q /Y "%SPRITEFIXFOLDER%\output\*.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\" > nul
	DEL /f /q "%SPRITEFIXFOLDER%\input\*"
	DEL /f /q "%SPRITEFIXFOLDER%\output\*"
	cd /d %ESRGANFOLDERPATH%
	set "stepspritefix=done"
	goto :PRECAFFE
	:nospritefix
	set "DUMP=DUMP"
	set "stepspritefix=done" 
	goto :PRECAFFE
	
	:PRECAFFE

	set CAFFEDUMPFILES=0
	call :progress
	IF NOT %PRECAFFE%==YES (
		set "stepprecaffe=done" 
		If %SPLIT%==YES goto :splitchannels 
		goto :upscaler
	)
	
	if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP md %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP
	if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1 md %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1

	if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPSKIPPED md %OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPSKIPPED
	if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1SKIPPED md %OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1SKIPPED
	:: dirty workaround to keep progress if the script is interrupted

	::::1
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\" %%a in (*.png) do (
		if exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1\%%~na.png" MOVE "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\%%~na.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPSKIPPED\%%~na.png" > nul
	)
	echo upscaling to x2...
	"%WAIFUCAFFECUIPATH%" -i "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%" -o "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1" --model_dir  "D:\Programmes\waifu2x-caffe\models\cunet" -m noise_scale --scale_ratio 2.0 --noise_level 0 --tta 0 --process cudnn > nul
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPSKIPPED\" %%a in (*.png) do (
		if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\%%~na.png" MOVE "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMPSKIPPED\%%~na.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\%%~na.png" > nul
	)
	
	::::: FINISHLINE
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1\" %%a in (*.png) do (
		if exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP\%%~na.png" MOVE "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1\%%~na.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1SKIPPED\%%~na.png" > nul
	)
	echo downscaling to x0.5...
	"%WAIFUCAFFECUIPATH%" -i "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1" -o "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP" --model_dir  "D:\Programmes\waifu2x-caffe\models\cunet" -m scale --scale_ratio 0.5 --noise_level 0 --tta 0 --process cudnn > nul
	for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1SKIPPED\" %%a in (*.png) do (
		if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1\%%~na.png" MOVE "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1SKIPPED\%%~na.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFETEMP1\%%~na.png" > nul
	)

	if %ERRORLEVEL% == 0 (
		set "stepprecaffe=done"
		If %SPLIT%==YES goto :splitchannels
		goto :upscaler
		
	)
	goto :unsuccessfulexit

		:splitchannels
		
		call :progress
		if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\alpha md %OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\alpha
		if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\noalpha md %OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\noalpha
		if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA md %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA
		if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA md %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA
		IF %PRECAFFE%==YES for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP\" %%a in (*.png) do set "filenametosplit=%%~na" && call :splitter %%i
		IF NOT %PRECAFFE%==YES for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%\" %%a in (*.png) do set "filenametosplit=%%~na" && call :splitter %%i
		
		if %ERRORLEVEL% == 0 set "stepsplitchannels=done" && goto :upscalersplit
		echo "Errors encountered during execution.  Exited with status: %errorlevel%"
		goto :unsuccessfulexit
		
			:splitter
			:: spawn multiple parallel instances of imagemagick for faster processing ?
			call :checkmagickinstances
			if %INSTANCES% LSS 10 (
				if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\alpha\%filenametosplit%.png" start /b "" magick "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP\%filenametosplit%.png" -alpha extract "%OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\alpha\%filenametosplit%.png" > nul
				if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\noalpha\%filenametosplit%.png" start /b "" magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP\%filenametosplit%.png" -alpha off "%OUTPUTFOLDER%\%GAME%\PROCESSING\SPLITTED\noalpha\%filenametosplit%.png" > nul
				goto :eof
			)
			ping -n 2 ::1 >nul 2>&1
			goto :splitter
			goto :eof

		:upscaler

		set UPSCALEDFILES=0
		call :progress
		echo Hello > "%OUTPUTFOLDER%\%GAME%\esrgan.log"
		IF %PRECAFFE%==YES start "" /b python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED" %ESRGANARG% >> "%OUTPUTFOLDER%\%GAME%\esrgan.log"
		IF %PRECAFFE%==YES start "" /b python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\CAFFEDUMP" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED" %ESRGANARG% --reverse >> "%OUTPUTFOLDER%\%GAME%\esrgan.log"
		IF NOT %PRECAFFE%==YES start "" /b python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED" %ESRGANARG% >> "%OUTPUTFOLDER%\%GAME%\esrgan.log"
		IF NOT %PRECAFFE%==YES start "" /b python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\%DUMP%" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED" %ESRGANARG% --reverse >> "%OUTPUTFOLDER%\%GAME%\esrgan.log"
		
		:waitendupscale
			
		set UPSCALEDFILES=0
		set DUMPFILES=0
		for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED\" %%a in (*.png) do set /a UPSCALEDFILES+=1
		for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\" %%a in (*.png) do set /a DUMPFILES+=1
		call :progress
		If %UPSCALEDFILES%==%DUMPFILES% if %ERRORLEVEL% == 0 set "stepupscaleesrgan=done" && goto :upscalerfinishline
		if NOT %ERRORLEVEL% == 0 goto :unsuccessfulexit
		timeout /t 5 /nobreak > nul
		goto :waitendupscale
		
		:upscalerfinishline
		IF %OPTIMIZE%==YES call %PNGQUANTPATH% --ext .png --force %OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED\*.png
		IF NOT %ALPHAFIX%==YES XCOPY "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED\*" "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\" > nul
		IF NOT %ALPHAFIX%==YES goto :installtextures
		call :progress
		echo 	--applying alphafix...
		for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED\" %%a in (*.png) do set "filenametomerge=%%~na" && call :transparencyfix %%i
		
		if %ERRORLEVEL% == 0 set && goto :installtextures
		echo "Errors encountered during execution.  Exited with status: %errorlevel%"
		goto :unsuccessfulexit
		
			:transparencyfix
			call :checkmagickinstances
			if %INSTANCES% LSS 50 (
				if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\%filenametomerge%.png" (
					IF %ALPHAFIX%==YES start /b "" magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\PREUPSCALED\%filenametomerge%.png" -fuzz "%fuzzblack%" -fill "rgba(0,0,0,0)" -opaque "rgba(0, 0, 0, 0)" "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\%filenametomerge%.png"
				)
				goto :eof
			)
			goto :transparencyfix
			goto :eof

		:upscalersplit

		set UPSCALEDNOALPHAFILES=0
		set UPSCALEDALPHAFILES=0
		call :progress
		
		start /b "" python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\splitted\noalpha" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA" %ESRGANARG% >> "%OUTPUTFOLDER%\%GAME%\esrgan.log"	
		start /b "" python "%ESRGANPATH%" "%ESRGANMODELARG%" --input "%OUTPUTFOLDER%\%GAME%\PROCESSING\splitted\alpha" --output "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA" %ESRGANARG% --alpha_mode 1 --binary_alpha >> "%OUTPUTFOLDER%\%GAME%\esrganalpha.log"
		
			:waitendupscale2
			
			set UPSCALEDNOALPHAFILES=0
			set UPSCALEDALPHAFILES=0
			set DUMPFILES=0
			for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA\" %%a in (*.png) do set /a UPSCALEDNOALPHAFILES+=1
			for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA\" %%a in (*.png) do set /a UPSCALEDALPHAFILES+=1
			for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\" %%a in (*.png) do set /a DUMPFILES+=1
			call :progress
			If %UPSCALEDNOALPHAFILES%==%DUMPFILES% If %UPSCALEDALPHAFILES%==%DUMPFILES% if %ERRORLEVEL% == 0 set "stepupscaleesrgansplit=done" && goto :mergechannels
			if NOT %ERRORLEVEL% == 0 goto :unsuccessfulexit
			timeout /t 5 /nobreak > nul
			goto :waitendupscale2

			:mergechannels
			
			call :progress
			if not exist %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED md %OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\
			for /r "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA\" %%a in (*.png) do set "filenametomerge=%%~na" && call :merger %%i
			
			if %ERRORLEVEL% == 0 set "stepmergechannels=done" && goto :installtextures
			echo "Errors encountered during execution.  Exited with status: %errorlevel%"
			goto :unsuccessfulexit
			
				:merger
				call :checkmagickinstances
				if %INSTANCES% LSS 10 (
					if not exist "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\%filenametomerge%.png" (
						IF %ALPHAFIX%==YES magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA\%filenametomerge%.png" -fuzz "%fuzzblack%" -fill "rgb(0,0,0)" -opaque black "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png"
						IF %ALPHAFIX%==YES magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png" -fuzz "%fuzzwhite%" -fill "rgb(255,255,255)" -opaque white "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png"
						::IF %ALPHAFIX%==YES magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png" -fuzz "%fuzzgray%" -fill "rgb(0,0,0)" -opaque "rgb(127,127,127)" "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png"
						IF %ALPHAFIX%==YES start /b "" magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA\%filenametomerge%.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHAFIXED\%filenametomerge%.png" -alpha off -compose CopyOpacity -composite "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\%filenametomerge%.png"
						IF NOT %ALPHAFIX%==YES start /b "" magick convert "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDNOALPHA\%filenametomerge%.png" "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALEDALPHA\%filenametomerge%.png" -alpha off -compose CopyOpacity -composite "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\%filenametomerge%.png"
					)
					goto :eof
				)
				timeout /t 1 /nobreak > nul
				goto :merger
				goto :eof

:::::::::::::::::::::::::::::::::::::::::: ESRGAN MODE END :::::::::::::::::::::::::::::::::::::::::::::::::::::::

:installtextures
::STEP FIVE

call :progress
If NOT %GAME%==TEST IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" XCOPY /Y /Q "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" "%MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\" > nul
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set datetime=%datetime:~0,8%%datetime:~8,6%
IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" XCOPY /S /Y /Q "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" "%OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP\%datetime%\UPSCALED\" > nul
IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING\DUMP\*.png" XCOPY /S /Y /Q "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" "%OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP\%datetime%\DUMP\" > nul
IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING\*.txt" XCOPY /S /Y /Q "%OUTPUTFOLDER%\%GAME%\PROCESSING\UPSCALED\*.png" "%OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP\%datetime%\" > nul
if %ERRORLEVEL% == 0 set "stepinstalltextures=done" && goto successfulexit
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :unsuccessfulexit

:successfulexit

call :progress
IF %stepinstalltextures%==done If "%1"=="" PAUSE
echo Removing temp folders...
call :progress > %OUTPUTFOLDER%\%GAME%\UPSCALED_BACKUP\%datetime%\upscale.log
IF EXIST "%OUTPUTFOLDER%\%GAME%\PROCESSING" rmdir "%OUTPUTFOLDER%\%GAME%\PROCESSING" /q /s > nul
If NOT %GAME%==TEST del "%MEMSTICKFOLDER%\PSP\TEXTURES\%ID%\new\*" /q > nul
If NOT "%1"=="" goto :eof
goto :choosegame

:unsuccessfulexit
echo ERROR, do not delete PROCESSING folders if you want to keep progress
PAUSE
goto :eof

:::::::::::::::::
:::::::::::::::::
:::::::::::::::::
:::::::::::::::::
:::::::::::::::::

:checkmagickinstances
for /f "usebackq" %%t in (`tasklist /fo csv /fi "imagename eq magick.exe"^|find /v /c ""`) do set INSTANCES=%%t
goto :eof

::::::::::::::
:::::::::::::::

:progress
cls
echo.
echo -- UPSCALING %GAME% %ID% --
echo -- MODE %MODE% --
echo.
echo Creating necessary folders... %stepcreatefolders%
IF %stepcreatefolders%==done echo Moving texture dump...  %stepmovedump%
IF %stepmovedump%==done If %REDOFULL%==YES echo REDOFULL enabled, using dump from backup... %stepredodump%
IF %MODE%==ESRGAN IF %stepredodump%==done goto :esrganmsg 

goto :endmsg
	:esrganmsg
	IF %SPRITEFIX%==YES IF %stepredodump%==done echo SPRITEFIX enabled, applying spritefix by Dinjerr... %stepspritefix%
	If %PRECAFFE%==YES (
		IF %stepspritefix%==done echo PRECAFFE enabled, upscaling x2 then downscaling back to 1.0 with waifu2xcaffe... %stepprecaffe%
	)
	If %SPLIT%==YES (
		IF %stepprecaffe%==done echo SPLIT enabled, splitting Alpha and rgb channels with ImageMagick... %stepsplitchannels%
		IF %stepsplitchannels%==done echo.
		IF %stepsplitchannels%==done echo Upscaling RGB and Alpha Separately with ESRGAN & echo. ARG: %ESRGANARG% & echo. MODEL: %ESRGANMODEL%
		IF %stepsplitchannels%==done echo.
		IF %stepsplitchannels%==done echo Upscaled RGB : %UPSCALEDNOALPHAFILES% / %DUMPFILES%
		IF %stepsplitchannels%==done echo Upscaled Alpha channels : %UPSCALEDALPHAFILES% / %DUMPFILES%
		IF %stepsplitchannels%==done echo.
		IF %stepupscaleesrgansplit%==done IF %ALPHAFIX%==YES echo ALPHAFIX, enabled
		IF %stepupscaleesrgansplit%==done IF %ALPHAFIX%==YES echo black fuzz: %fuzzblack%
		IF %stepupscaleesrgansplit%==done IF %ALPHAFIX%==YES echo white fuzz: %fuzzwhite%
		::IF %stepupscaleesrgansplit%==done IF %ALPHAFIX%==YES echo gray fuzz: %fuzzgray%
		IF %stepupscaleesrgansplit%==done echo Merging upscaled RGB and Alpha... %stepmergechannels%	
		IF %stepmergechannels%==done echo Installing textures... %stepinstalltextures%
	)
	If NOT %SPLIT%==YES (
		IF %stepprecaffe%==done echo.
		IF %stepprecaffe%==done echo Upscaling with ESRGAN & echo. ARG: %ESRGANARG% & echo. MODEL: %ESRGANMODEL%
		IF %stepprecaffe%==done echo.
		IF %stepprecaffe%==done echo Upscaled textures : %UPSCALEDFILES% / %DUMPFILES%
		IF %stepprecaffe%==done echo.
		IF %stepupscaleesrgan%==done IF %ALPHAFIX%==YES echo ALPHAFIX, enabled
		IF %stepupscaleesrgan%==done IF %ALPHAFIX%==YES echo black fuzz: %fuzzblack%
		IF %stepupscaleesrgan%==done echo Installing textures... %stepinstalltextures%
	)
	goto :endmsg

:endmsg
IF %stepinstalltextures%==done echo Game dump upscale complete ! Press a button to remove temporary/dump folders (backup made) and continue.
IF %stepinstalltextures%==done echo.
goto :eof

:::::
:::::::::::


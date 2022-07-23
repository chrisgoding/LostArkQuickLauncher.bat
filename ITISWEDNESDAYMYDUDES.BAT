::ITISWEDNESDAYMYDUDES.BAT
:: 
:: Use this to put the folders back where they belong on patch day.
@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

Call :SteamLocation
Call :LostArkAudioLocation
Call :AudioFileMover
goto :eof


:::::::::::::
::FUNCTIONS::
:::::::::::::

:SteamLocation
	if exist SteamLocation.txt (for /f "tokens=1" %%i in ( SteamLocation.txt ) do (set SteamPath=%%i))
	if exist %SteamPath% exit /b
	::If the text file already exists, we set the contents of it as a variable %SteamPath%, if that path is valid.
	echo First we need the path to your steam.exe because I don't want to assume steam is running already.
	echo I also can't assume you picked the default location for steam installation.
	echo Please paste the path to the folder containing steam.exe here (For example C:\Program Files (x86)\Steam)
	set /p SteamPath=
	if exist "%SteamPath%\steam.exe" (echo %SteamPath% > SteamLocation.txt&&exit /b) else (cls&&goto SteamLocation)
	::If you typod it or lied and put the wrong path in, this will clear the screen and loop back so you can try again.

:LostArkAudioLocation
	::I can't assume your steamapps are actually in your steam program files folder, some people move them. I do attempt to check it here and if it is then we can skip asking.
	if exist LostArkAudioLocation.txt (for /f "tokens=1-5" %%j in ( LostArkAudioLocation.txt ) do (set LostArkAudioPath=%%j %%k %%l %%m %%n))
	::what's up with all the letters in the variables? gotta handle any possible spaces in your paths. There's probably a less hacky way of dealing with this but I don't feel like figuring it out rn.
	call :Trim LostArkAudioPath %LostArkAudioPath%
	::this removes the extra spaces in the variable.
	if exist %LostArkAudioPath% exit /b
	if exist "%SteamPath%\steamapps\common\Lost Ark\EFGame\ReleasePC\WwiseAudio" (Set LostArkAudioPath="%SteamPath%\steamapps\common\Lost Ark\EFGame\ReleasePC\WwiseAudio")
	echo %LostArkAudioPath% > LostArkAudioLocation.txt
	if exist %LostArkAudioPath% exit /b
	Echo Looks like your steamapps are in a different folder than your steam.exe. I'm not one to judge, but you'll need to tell me where the lost ark audio files are to continue.
	Echo it should look something like $whereveryouputyoursteamapps$\steamapps\common\Lost Ark\EFGame\ReleasePC\WwiseAudio
	Echo Paste here:
	set /p LostArkAudioPath=
	if exist "%LostArkAudioPath%" (echo "%LostArkAudioPath%" > LostArkAudioLocation.txt&&exit /b) else (cls&&goto :LostArkAudioLocation)
	::If you typod it or lied and put the wrong path in, this will clear the screen and loop back so you can try again.

:Trim
	::Shamelessly stolen from https://stackoverflow.com/a/26079981 No need to reinvent the wheel if someone already has an elegant solution to your problem.
	SetLocal EnableDelayedExpansion
	set Params=%*
	for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
	exit /b

:AudioFileMover
	DIR "%~dp0" /B /AD > LangPacks.txt
	::lists the folders in the current directory, and saves that data to a file.
	for /f "tokens=1" %%p in (LangPacks.txt) do (move /y "%~dp0%%p" %LostArkAudioPath%"\%%p")
	::For each line of LangPacks.txt, move the folder to the current directory.
	exit /b

:eof
popd
endlocal
exit

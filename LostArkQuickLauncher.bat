:: LOSTARKQUICKLOAD.BAT
::
:: Everything that's preceded by :: is a comment and is not processed. I did my best to comment what everything does.
:: PLEASE ACTUALLY READ THIS. Nothing in here is all that complicated, and learning batch files can really propel your IT career.
:: Learn more about the various commands at ss64.com
:: You should save this in a folder that does not need admin rights to read and write to. 
:: If you put this directly on your desktop, it'll create text files that clutter your desktop, as well as dump the audio files there. 
:: You can put this on a secondary drive to keep the ~23gb of audio files off your primary.
:: I recommend making a folder to put this in, then creating a shortcut to this batch file and place the shortcut on your desktop. 
:: You can even change the icon to the lost ark icon in the shortcut properties.
:: 
:: Brief summary of what it does:
:: It asks where steam is if you haven't told it already, then launches steam if you haven't launched it yet.
:: It tries to find the lost ark audio file path based on where you told it steam is, and if it isn't there it asks.
::
::
:: it did take me a few hours to write and test so if you want to send me a few G I'd appreciate it, but please don't feel pressured to do so, 
:: because I had fun making it.
:: -Chriscasting, Regulus
:: f2p btw

@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"
::This tells the batch file to look for the text files in the same folder the batch file is in. "%~dp0" is a variable for the current directory.

Call :SteamLocation
Call :SteamRunner
Call :LostArkAudioLocation
Call :AudioFileMover
Call :LaunchGame
goto eof

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

:SteamRunner
	tasklist | find /i "steam.exe"
	if %errorlevel%==0 exit /b
	::Tasklist displays a list of running programs. We pipe that into "find" and check if steam's running. If it is, then the errorlevel of the find will be 0, and thus we don't need to run and this function exits.
	start "Steam" "%SteamPath%\steam.exe" -no-browser +open steam://open/minigameslist
	::This launches the minimal version of steam. You can delete everything after %steamPath% in the above line if you hate that.
	timeout 5 >nul
	::we wait 5 seconds here for steam to launch. Adjust if needed.
	exit /b

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

:AudioFileMover
	DIR %LostArkAudioPath% /B /AD > LangPacks.txt
	::lists the folders in your audio path, and saves that data to a file.
	if not exist PreferredLanguage.txt call :FindPreferredLanguage
	for /f "tokens=1" %%o in (PreferredLanguage.txt) do (set PreferredLanguage=%%o)
	type LangPacks.txt | findstr /v %PreferredLanguage% > LangPacks1.txt
	::This line modified from https://stackoverflow.com/a/418949, I'm using it to remove the preferred language from the list of folders to move.
	del LangPacks.txt /f /s /q
	::gotta delete the original LangPacks.txt in order to rename the modified one.
	ren LangPacks1.txt LangPacks.txt
	for /f "tokens=1" %%p in (LangPacks.txt) do (move /y %LostArkAudioPath%"\%%p" "%~dp0%%p")
	::For each line of LangPacks.txt, move the folder to the current directory.
	exit /b

:Trim
	::Shamelessly stolen from https://stackoverflow.com/a/26079981 No need to reinvent the wheel if someone already has an elegant solution to your problem.
	SetLocal EnableDelayedExpansion
	set Params=%*
	for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
	exit /b

:FindPreferredLanguage
	Echo What language folder do you want to keep? Please copy and paste from the following:
	type LangPacks.txt
	set /p PreferredLanguage=
	echo %PreferredLanguage%> PreferredLanguage.txt
	exit /b

:LaunchGame
	"%SteamPath%\Steam.exe" steam://rungameid/1599340
	exit /b

:eof
popd
exit

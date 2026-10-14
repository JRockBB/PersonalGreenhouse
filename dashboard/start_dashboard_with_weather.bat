@echo off
setlocal
cd /d "%~dp0.."
set "DYAD_JULIA=%USERPROFILE%\.julia\juliaup-depots\juliahub.com\juliaup\julia-1.12.7+dyad-3x4x0.x86.w64.msvc\bin\julia.exe"
if not exist "%DYAD_JULIA%" set "DYAD_JULIA=%USERPROFILE%\.julia\juliaup-depots\juliahub.com\juliaup\julia-1.12.7+dyad-3x3x0.x86.w64.msvc\bin\julia.exe"
if not exist "%DYAD_JULIA%" goto :nojulia
set /p "GREENHOUSE_WEATHER=Enter full path to EPW or hourly weather CSV: "
if not exist "%GREENHOUSE_WEATHER%" goto :noweather
echo Starting dashboard using %GREENHOUSE_WEATHER%
echo Loading 8760 weather rows and simplifying the model may take several minutes.
"%DYAD_JULIA%" --project=. dashboard\server.jl
goto :done
:noweather
echo Weather file not found.
goto :done
:nojulia
echo Dyad Julia runtime not found. Open this project in Dyad Studio first.
:done
pause

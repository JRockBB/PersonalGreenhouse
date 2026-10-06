@echo off
setlocal
cd /d "%~dp0.."
set "DYAD_JULIA=%USERPROFILE%\.julia\juliaup-depots\juliahub.com\juliaup\julia-1.12.7+dyad-3x3x0.x86.w64.msvc\bin\julia.exe"

if not exist "%DYAD_JULIA%" goto :nojulia

echo Starting Personal Greenhouse dashboard with Dyad Julia 1.12.7...
echo Loading and simplifying the greenhouse model may take a minute.
"%DYAD_JULIA%" --project=. dashboard\server.jl
goto :done

:nojulia
echo The Dyad Julia runtime was not found at:
echo %DYAD_JULIA%
echo Open this project in Dyad Studio or update DYAD_JULIA in this batch file.
goto :done

:done
pause

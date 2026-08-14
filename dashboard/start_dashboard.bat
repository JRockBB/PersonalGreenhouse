@echo off
cd /d "%~dp0.."
echo Starting Personal Greenhouse dashboard...
echo First startup may take a minute while Julia loads and simplifies the model.
julia --project=. dashboard\server.jl
pause

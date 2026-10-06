@echo off
setlocal
set "ART=C:\Users\jmurp\.julia\artifacts\e52e2e20e817dea175c440c5f2946ff60e59df9f"
set "URL=https://github.com/JuliaBinaryWrappers/MUMPS_seq_jll.jl/releases/download/MUMPS_seq-v500.900.0+0/MUMPS_seq.v500.900.0.x86_64-w64-mingw32-libgfortran5.tar.gz"
echo Restoring the corrupted Julia MUMPS artifact...
if exist "%ART%" rmdir /s /q "%ART%"
mkdir "%ART%"
curl.exe -L "%URL%" -o "%TEMP%\mumps_seq.tar.gz"
if errorlevel 1 goto :fail
tar.exe -xzf "%TEMP%\mumps_seq.tar.gz" -C "%ART%"
if errorlevel 1 goto :fail
del "%TEMP%\mumps_seq.tar.gz"
echo Artifact restored. Restart VS Code / Dyad Studio before compiling.
exit /b 0
:fail
echo Restore failed. Check network access, then run this file again.
exit /b 1

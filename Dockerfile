
FROM mcr.microsoft.com/windows/servercore:1909

LABEL "fr.inrae.os"="Windows"
LABEL "fr.inrae.windows.servercore.version"=1909
LABEL "fr.inrae.buildtools.version"=16
LABEL "fr.inrae.ifort.version"=2022.1.0.134

SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
RUN curl -SL --output vs_buildtools.exe https://aka.ms/vs/16/release/vs_BuildTools.exe

# Install Build Tools
#  (Error code 3010 is meant for install successful but a system restart is required)

RUN start /wait `
      vs_buildtools.exe `
        --quiet `
        --wait `
        --norestart `
        --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools `
    || (echo ERRORLEVEL=%ERRORLEVEL% `
        || IF "%ERRORLEVEL%"=="3010" (EXIT /B 0) `
           ELSE (EXIT /B "%ERRORLEVEL%") )
# Cleanup
RUN del /q vs_buildtools.exe

ENV DOWNLOAD_URL=https://registrationcenter-download.intel.com/akdlm/irc_nas/18716/w_fortran-compiler_p_2022.1.0.139_offline.exe
ENV SETUP_FILENAME=setup_ifort.exe

# Download and install Intel fortran compiler
RUN curl -SL --output %SETUP_FILENAME% %DOWNLOAD_URL%
RUN start /wait %SETUP_FILENAME% --silent --remove-extracted-files yes -a --silent --action=install --eula=accept
RUN del /q %SETUP_FILENAME%




ENTRYPOINT ["C:\\Program Files (x86)\\Intel\\oneAPI\\setvars.bat", "intel64", "vs2019", "&&"]
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
 
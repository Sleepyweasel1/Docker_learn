FROM mcr.microsoft.com/windows/nanoserver:1903
#FROM mcr.microsoft.com/windows/servercore:ltsc2019

COPY ["./DSC_Modules", "C:/Program Files/WindowsPowerShell/Modules/"]

WORKDIR /dsc_mof

COPY ./DSC_MOF_GEN.PS1 ./


RUN powershell.exe -Command Add-WindowsFeature Web-Server ; \
Add-WindowsFeature DSC-Service ; 

RUN powershell -file C:\dsc_mof\DSC_MOF_GEN.ps1

CMD [powershell.exe]

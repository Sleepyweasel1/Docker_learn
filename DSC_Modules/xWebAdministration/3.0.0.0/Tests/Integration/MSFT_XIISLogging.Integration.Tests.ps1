$script:DSCModuleName = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xIISLogging'

#region HEADER

# Integration Test Template Version: 1.1.0
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration

#endregion

[String] $tempName = "$($script:DSCResourceName)_" + (Get-Date).ToString("yyyyMMdd_HHmmss")


try {
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $configFile

    $null = Backup-WebConfiguration -Name $tempName

    Describe "$($script:DSCResourceName)_Rollover" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Rollover -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Changing Logging Rollover Settings ' -test {

            Invoke-Expression -Command "$($script:DSCResourceName)_Rollover -OutputPath `$TestDrive"
            Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force

            $currentLogSettings = Get-WebConfiguration -filter '/system.applicationHost/sites/siteDefaults/Logfile'

            $currentLogSettings.directory | Should Be 'C:\IISLogFiles'
            $currentLogSettings.logExtFileFlags | Should Be 'Date,Time,ClientIP,UserName,ServerIP'
            $currentLogSettings.logformat | Should Be 'W3C'
            $currentLogSettings.logTargetW3C | Should Be 'File,ETW'
            $currentLogSettings.period | Should Be 'Hourly'
            $currentLogSettings.localTimeRollover | Should Be 'True'
            $currentLogSettings.customFields.Collection[0].LogFieldName | Should Be 'ClientEncoding'
            $currentLogSettings.customFields.Collection[0].SourceName | Should Be 'Accept-Encoding'
            $currentLogSettings.customFields.Collection[0].SourceType | Should Be 'RequestHeader'
            $currentLogSettings.customFields.Collection[1].LogFieldName | Should Be 'X-Powered-By'
            $currentLogSettings.customFields.Collection[1].SourceName | Should Be 'ASP.NET'
            $currentLogSettings.customFields.Collection[1].SourceType | Should Be 'ResponseHeader'
       }
    }

    Describe "$($script:DSCResourceName)_Truncate" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:DSCResourceName)_Truncate -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion
        It 'Changing Loggging Truncate Settings ' -test {

            Invoke-Expression -Command "$($script:DSCResourceName)_Truncate -OutputPath `$TestDrive"
            Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force

            $currentLogSettings = Get-WebConfiguration -filter '/system.applicationHost/sites/siteDefaults/Logfile'

            $currentLogSettings.directory | Should Be 'C:\IISLogFiles'
            $currentLogSettings.logExtFileFlags | Should Be 'Date,Time,ClientIP,UserName,ServerIP'
            $currentLogSettings.logformat | Should Be 'W3C'
            $currentLogSettings.logTargetW3C | Should Be 'File,ETW'
            $currentLogSettings.TruncateSize | Should Be '2097152'
            $currentLogSettings.localTimeRollover | Should Be 'True'
            $currentLogSettings.customFields.Collection[0].LogFieldName | Should Be 'ClientEncoding'
            $currentLogSettings.customFields.Collection[0].SourceName | Should Be 'Accept-Encoding'
            $currentLogSettings.customFields.Collection[0].SourceType | Should Be 'RequestHeader'
            $currentLogSettings.customFields.Collection[1].LogFieldName | Should Be 'X-Powered-By'
            $currentLogSettings.customFields.Collection[1].SourceName | Should Be 'ASP.NET'
            $currentLogSettings.customFields.Collection[1].SourceType | Should Be 'ResponseHeader'
        }
    }
}
finally
{
    #region FOOTER
    Restore-WebConfiguration -Name $tempName
    Remove-WebConfigurationBackup -Name $tempName

    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}

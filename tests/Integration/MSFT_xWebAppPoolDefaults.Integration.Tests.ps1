#requires -Version 4.0

<<<<<<< HEAD:Tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
$script:DSCModuleName   = 'xWebAdministration'
$script:DSCResourceName = 'MSFT_xWebAppPoolDefaults'
=======
$script:dscModuleName      = 'xWebAdministration'
$script:dscResourceName    = 'MSFT_xWebAppPoolDefaults'
>>>>>>> Added continuous delivery with a new CI pipeline (#549):tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

<<<<<<< HEAD:Tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration 

#endregion

# Test Setup
if ((Get-Service -Name 'W3SVC').Status -ne 'Running')
{
    Start-Service -Name 'W3SVC'
}

$tempBackupName = "$($script:DSCResourceName)_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Using try/finally to always cleanup even if something awful happens.

=======
$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper\CommonTestHelper.psm1') -Force

$tempName = "$($script:dscResourceName)_" + (Get-Date).ToString("yyyyMMdd_HHmmss")

>>>>>>> Added continuous delivery with a new CI pipeline (#549):tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
try
{
    # Create configuration backup
    
    Backup-WebConfiguration -Name $tempBackupName | Out-Null

    #region Integration Tests

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {

        #region Default Tests

<<<<<<< HEAD:Tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
        It 'Should be able to compile and apply without throwing' {
            {
                Invoke-Expression -Command (
                    '{0}_Config -OutputPath $TestDrive -ConfigurationData $ConfigData -ErrorAction Stop' -f
                    $script:DSCResourceName
                )

                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Force -Wait -Verbose
            } | Should Not Throw
=======
    Describe "$($script:dscResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($script:dscResourceName)_Config -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
>>>>>>> Added continuous delivery with a new CI pipeline (#549):tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should Not Throw
        }

        #endregion

        It 'Should have set the resource and all the parameters should match' {

            $currentConfiguration = Get-DscConfiguration

            foreach ($parameter in $TestParameters.GetEnumerator())
            {
                Write-Verbose -Message "The $($parameter.Name) property should be set."

                if ($parameter.Name -eq 'Credential')
                {
                    $appPoolDefaults = Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/applicationPoolDefaults' 

                    $appPoolDefaults.processModel.userName |
                    Should Be $TestParameters['Credential'].UserName

                    $appPoolDefaults.processModel.password |
                    Should Be $TestParameters['Credential'].GetNetworkCredential().Password
                }
                elseif ($parameter.Name -eq 'ApplyTo')
                {
                    # ignored.
                }
                else
                {
                    $currentConfiguration."$($parameter.Name)" |
                    Should Be $TestParameters[$parameter.Name]
                }
<<<<<<< HEAD:Tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
            }

        }

        It 'Actual configuration should match the desired configuration' {
            Test-DscConfiguration -Verbose | Should Be $true
=======

                Invoke-Expression -Command "$($script:dscResourceName)_ManagedRuntimeVersion -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            }  | should not throw

            # get the configured value again
            $changedValue = (Get-WebConfigurationProperty -pspath $constPsPath -filter $constAPDFilter -name managedRuntimeVersion).Value

            # compare it to the one we just tried to set.
            $changedValue | should be $env:PesterManagedRuntimeVersion
        }

        It 'Changing IdentityType' {
            # get the current value
            [string] $originalValue = (Get-WebConfigurationProperty `
                -PSPath $constPsPath `
                -Filter $constAPDFilter/processModel `
                -Name identityType)

            if ($originalValue -eq 'ApplicationPoolIdentity')
            {
                $env:PesterApplicationPoolIdentity = 'LocalService'
            }
            else
            {
                $env:PesterApplicationPoolIdentity = 'ApplicationPoolIdentity'
            }

            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:dscResourceName)_AppPoolIdentityType -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = (Get-WebConfigurationProperty -PSPath $constPsPath -Filter $constAPDFilter/processModel -Name identityType)

            $changedValue | Should Be $env:PesterApplicationPoolIdentity
        }


        It 'Changing LogFormat' {
            [string] $originalValue = Get-SiteValue 'logFile' 'logFormat'

            if ($originalValue -eq 'W3C')
            {
                $env:PesterLogFormat =  'IIS'
            }
            else
            {
                $env:PesterLogFormat =  'W3C'
            }

            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:dscResourceName)_LogFormat -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = Get-SiteValue 'logFile' 'logFormat'

            $changedValue | Should Be $env:PesterALogFormat
        }

        It 'Changing Default AppPool' {
            # get the current value

            [string] $originalValue = Get-SiteValue 'applicationDefaults' 'applicationPool'

            $env:PesterDefaultPool =  'DefaultAppPool'
            # Compile the MOF File
            {
                Invoke-Expression -Command "$($script:dscResourceName)_DefaultPool -OutputPath `$TestDrive"
                Start-DscConfiguration -Path $TestDrive -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw

            $changedValue = Get-SiteValue 'applicationDefaults' 'applicationPool'
            $changedValue | should be $env:PesterDefaultPool
>>>>>>> Added continuous delivery with a new CI pipeline (#549):tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
        }

    }

    #endregion
}
finally
{
<<<<<<< HEAD:Tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1
    #region FOOTER
    Restore-WebConfiguration -Name $tempBackupName
    Remove-WebConfigurationBackup -Name $tempBackupName
=======
    Restore-WebConfigurationWrapper -Name $tempName

    Remove-WebConfigurationBackup -Name $tempName
>>>>>>> Added continuous delivery with a new CI pipeline (#549):tests/Integration/MSFT_xWebAppPoolDefaults.Integration.Tests.ps1

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

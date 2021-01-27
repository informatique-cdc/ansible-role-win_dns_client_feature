# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

.$(Join-Path -Path $Here -ChildPath 'test_utils.ps1')

# Update Pester if needed
Update-Pester

#Get Function Name
$moduleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Resolve Path to Module path
$ansibleModulePath = "$Here\..\..\library\$moduleName.ps1"

Invoke-TestSetup

Function Invoke-AnsibleModule {
    [CmdletBinding()]
    Param(
        [hashtable]$params
    )

    begin {
        $global:complex_args = @{
            "_ansible_check_mode" = $false
            "_ansible_diff"       = $true
        } + $params
    }
    Process {
        . $ansibleModulePath
        return $module.result
    }
}

$RegistryPath = "HKLM:\SOFTWARE\policies\Microsoft\Windows NT\DNSClient"

try {

    Describe 'win_dns_client_feature validation' {

        Context "Return the configuration only" {

            It 'Setting should return no changed' {

                $params = @{}
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeFalse
            }
        }

        Context 'Use the Multicast Name Resolution (LLMNR) is set to "Disable"' {

            It 'Setting should return changed' {

                Mock Test-Path -ParameterFilter { $Path -eq $RegistryPath } -MockWith { return $false}
                Mock New-Item -ParameterFilter { $Path -eq $RegistryPath } -MockWith {}
                Mock New-ItemProperty -ParameterFilter { $Path -eq $RegistryPath } -MockWith { }
                Mock Get-ItemProperty -ParameterFilter { $Name -eq 'EnableMulticast' -and $Path -eq $RegistryPath } -MockWith {
                    return $null
                }

                $params = @{
                    enable_multi_cast = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeTrue
            }

            It 'Setting should return changed' {

                Mock Test-Path -ParameterFilter { $Path -eq $RegistryPath } -MockWith { return $true}
                Mock Set-ItemProperty -ParameterFilter { $Path -eq $RegistryPath } -MockWith { }

                Mock Get-ItemProperty -ParameterFilter { $Name -eq 'EnableMulticast' -and $Path -eq $RegistryPath } -MockWith {
                    return @{ EnableMulticast = 1 }
                }

                $params = @{
                    enable_multi_cast = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeTrue
            }
            It 'Setting should return unchanged' {

                Mock Get-ItemProperty -ParameterFilter { $Name -eq 'EnableMulticast' -and $Path -eq $RegistryPath } -MockWith {
                    return @{ EnableMulticast = 0 }
                }

                $params = @{
                    enable_multi_cast = $false
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeFalse
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}
#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options             = @{
        enable_multi_cast = @{ type = "bool"; }
    }
    supports_check_mode = $true
}
$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$check_mode = $module.CheckMode
$diff_before = @{ }
$diff_after = @{ }

<#
    .SYNOPSIS
        Returns the current DNS Client features.
    .OUTPUTS
        Returns a hashtable containing the values.
#>
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $enableMultiCastRegistryKey = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\policies\Microsoft\Windows NT\DNSClient' `
        -Name EnableMulticast `
        -ErrorAction SilentlyContinue

    if ($enableMultiCastRegistryKey) {
        $enableMultiCast = ($enableMultiCastRegistryKey.EnableMulticast -eq 1)
    }
    else {
        # if the key does not exist, then set the default which is enabled.
        $enableMultiCast = $true
    }

    $settings = @{
        enable_multi_cast = $enableMultiCast
    }
    return $settings
}

<#
    .SYNOPSIS
        Sets the current configuration for the DNS client.
    .PARAMETER enable_multi_cast
        Specifies if the Multicast Name Resolution (LLMNR) is enabled.
        #>
function Set-TargetResource {
    param
    (
        [Parameter()]
        [System.Boolean]
        $enable_multi_cast
    )
    # Get the current values of the DNS Client features
    $currentState = Get-TargetResource

    $module.Result.changed = $false

    $EnableMultiCast = $currentState.enable_multi_cast
    if ($PSBoundParameters.ContainsKey('enable_multi_cast')) {
        if ($enable_multi_cast -ne $EnableMultiCast) {

            $diff_before.enable_multi_cast = $EnableMultiCast
            $diff_after.enable_multi_cast = $enable_multi_cast

            if (-not $check_mode) {
                $desiredValue = if ($enable_multi_cast) { 1 } else { 0 }

                $regPath = "HKLM:\SOFTWARE\policies\Microsoft\Windows NT\DNSClient"
                $regProperty = "EnableMulticast"
                If (-not(Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                    New-ItemProperty -Path $regPath -Name $regProperty -Value $desiredValue -PropertyType DWORD -Force | Out-Null
                }
                else {
                    Set-ItemProperty -Path $regPath -Name $regProperty -Value $desiredValue
                }
            }
        }
    }

    if ($diff_after.Keys.Count -gt 0) {
        $module.Result.changed = $true
    }
}

$setTargetResourceParameters = @{}

foreach ($key in $module.Params.Keys) {
    if ($null -ne $module.Params[$key]) {
        $setTargetResourceParameters.$key = $module.Params[$key]
    }
}

Set-TargetResource @setTargetResourceParameters

if ($module.Result.changed) {
    $module.Diff.before = $diff_before
    $module.Diff.after = $diff_after
}

$module.ExitJson()
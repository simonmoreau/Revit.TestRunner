############################################################################################################
#
# Script to install the Revit.testRunner Addin for Autodesk Revit
# The .addin file will be copied to the addin folder of revit in %ProgramData%
#
# The executable assembly will be set in the target addin file on basis of the folder passed as argument.
# 
#
# Created by Tobias Flöscher, Geberit Verwaltungs AG
# Date: 01.03.2018
#
# To enable PowerShell Scripts run in a Command Prompt as Administrator:
# c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -command set-executionpolicy unrestricted
#
# InputParameters:
# - Build configuration => last 4 characters represets Revit version. ex: Debug2019 -> Revit v2019
# - Project Name        => .addin file with the name of the project must exist. ex: Revit.TestRunner.addin
# - Addin source path   => path of the above defined .addin file
# - Target Path         => path of the executing assembly
#
############################################################################################################

param (
    [string]$configuration = "Debug2022",
    [string]$projectName = "Revit.TestRunner",
    [string]$addinSourceDir = "",
    [string]$targetPath = ""
)

Write-Host "##### Run InstallAddinForDebuggingScript.ps1 #####"

# Exit Codes
$errorIncorrectparamConfiguration = 101
$errorIncorrectparamProjectName = 102
$errorIncorrectparamAddinDir = 103
$errorIncorrectparamTargetPath = 104

$errorAddinFileDoesNotExist = 111
$errorAddinTargetDoesNotExist = 113

# General Parameters
$addinRootPath = $env:APPDATA
$addinPathRelative = "Autodesk\Revit\Addins\"

# Validate Input parameters
if ($configuration.length -lt 4){
    Write-Host "param configuration must have at least 4 characters"
    exit $errorIncorrectparamConfiguration
}
$revitVersion = $configuration.Substring($configuration.Length-4, 4)
Write-Host "Install for Revit version "$revitVersion

if($projectName.Equals("")){
    Write-Host "param projectName must not be empty"
    exit $errorIncorrectparamProjectName
}

if(!(Test-Path $addinSourceDir)){
    Write-Host "addin does not exist exist '$addinSourceDir'"
    exit $errorIncorrectparamAddinDir
}

if(!(Test-Path $targetPath)){
    Write-Host "target path does not exist '$targetPath'"
    exit $errorIncorrectparamTargetPath
}

# sign the dll
$thumbPrint = "e729567d4e9be8ffca04179e3375b7669bccf272"
$cert=Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where { $_.Thumbprint -eq $thumbPrint}

Set-AuthenticodeSignature -FilePath $TargetPath -Certificate $cert -IncludeChain All -TimestampServer "http://timestamp.comodoca.com/authenticode"


# addin source file
$addinFileName = "{0}.addin" -f $projectName
$sourceAddinFile = Join-Path -Path $addinSourceDir -ChildPath $addinFileName
#Write-Host "Source addin File "$sourceAddinFile

if(!(Test-Path $sourceAddinFile)){
    Write-Host "source addin file does not exist '$sourceAddinFile'"
    exit $errorAddinFileDoesNotExist
}

$addinPath = Join-Path -Path $addinRootPath -ChildPath $addinPathRelative
$addinVersionPath = Join-Path -Path $addinPath -ChildPath $revitVersion
if(!(Test-Path $addinVersionPath)){
    Write-Host "addin target path does not exist '$addinVersionPath'"
    exit $errorAddinTargetDoesNotExist
}

$targetAddinFile = "{0}\{1}" -f $addinVersionPath, $addinFileName

# Copy addin file to target path
Write-Host "Install addin file "$targetAddinFile
# Delete-I
Copy-Item $sourceAddinFile -Destination $addinVersionPath -Force

# Manipulate target addin File
Write-Host "Executing assembly "$targetPath
(Get-Content $targetAddinFile).Replace('###insertExecutingAssembly###', $targetPath) | Set-Content $targetAddinFile

# SIG # Begin signature block
# MIIo5wYJKoZIhvcNAQcCoIIo2DCCKNQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUurSOCaAGKW9jnHe5M6OsOvnx
# pWiggiLOMIIEMjCCAxqgAwIBAgIBATANBgkqhkiG9w0BAQUFADB7MQswCQYDVQQG
# EwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxm
# b3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENl
# cnRpZmljYXRlIFNlcnZpY2VzMB4XDTA0MDEwMTAwMDAwMFoXDTI4MTIzMTIzNTk1
# OVowezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQ
# MA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAf
# BgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAL5AnfRu4ep2hxxNRUSOvkbIgwadwSr+GB+O5AL686td
# UIoWMQuaBtDFcCLNSS1UY8y2bmhGC1Pqy0wkwLxyTurxFa70VJoSCsN6sjNg4tqJ
# VfMiWPPe3M/vg4aijJRPn2jymJBGhCfHdr/jzDUsi14HZGWCwEiwqJH5YZ92IFCo
# kcdmtet4YgNW8IoaE+oxox6gmf049vYnMlhvB/VruPsUK6+3qszWY19zjNoFmag4
# qMsXeDZRrOme9Hg6jc8P2ULimAyrL58OAd7vn5lJ8S3frHRNG5i1R8XlKdH5kBjH
# Ypy+g8cmez6KJcfA3Z3mNWgQIJ2P2N7Sw4ScDV7oL8kCAwEAAaOBwDCBvTAdBgNV
# HQ4EFgQUoBEKIz6W8Qfs4q8p74Klf9AwpLQwDgYDVR0PAQH/BAQDAgEGMA8GA1Ud
# EwEB/wQFMAMBAf8wewYDVR0fBHQwcjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9j
# YS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNqA0oDKGMGh0dHA6Ly9j
# cmwuY29tb2RvLm5ldC9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDANBgkqhkiG
# 9w0BAQUFAAOCAQEACFb8AvCb6P+k+tZ7xkSAzk/ExfYAWMymtrwUSWgEdujm7l3s
# Ag9g1o1QGE8mTgHj5rCl7r+8dFRBv/38ErjHT1r0iWAFf2C3BUrz9vHCv8S5dIa2
# LX1rzNLzRt0vxuBqw8M0Ayx9lt1awg6nCpnBBYurDC/zXDrPbDdVCYfeU0BsWO/8
# tqtlbgT2G9w84FoVxp7Z8VlIMCFlA2zs6SFz7JsDoeA3raAVGI/6ugLOpyypEBMs
# 1OUIJqsil2D4kF501KKaU73yqWjgom7C12yxow+ev+to51byrvLjKzg6CYG1a4XX
# vi3tPxq3smPi9WIsgtRqAEFQ8TmDn5XpNpaYbjCCBSwwggQUoAMCAQICEQDLfPNQ
# C5p3ocmlVHGEWq2zMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAkdCMRswGQYD
# VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEkMCIGA1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBT
# aWduaW5nIENBMB4XDTIxMDQyMzAwMDAwMFoXDTI0MDQyMjIzNTk1OVowgZIxCzAJ
# BgNVBAYTAkZSMRIwEAYDVQQIDAlOb3JtYW5kaWUxETAPBgNVBAcMCExlIEhhdnJl
# MS0wKwYDVQQKDCRFdHVkZXMgZXQgQXBwbGljYXRpb25zIEluZm9ybWF0aXF1ZXMx
# LTArBgNVBAMMJEV0dWRlcyBldCBBcHBsaWNhdGlvbnMgSW5mb3JtYXRpcXVlczCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOucHNY1pSJvpeqQrvQ3ApBC
# mUNUw5GPpJONHUuyuq8iS+A1QtHn2vlH/YlSrzvfX7rAaQACvI0GY0FGMpz5mPR0
# AElsGYnqbv2OyQrekJfC+/7TI0aCY9bLpzwJQQ0ez4MHJpkm8BKOdCyFnu3eEa5i
# L4Om7g1VXtfJrzOQcnJmaakDCtk2g+LYAGG6GczNz6JP3jlr7vhHD9uE2qdY7ftV
# bQ2sc/xWMdmRoEfmSb0MpALTapNFJIAirTZ5QjOJfCCiM4FMI0sR41K6U2rDXsgj
# osFuZDpGeRle/I+B0o1qCTEgXR6VqIKTYsQ5iVv+mIcbDvZ/ranu9hxeozsfBdEC
# AwEAAaOCAZAwggGMMB8GA1UdIwQYMBaAFA7hOqhTOjHVir7Bu61nGgOFrTQOMB0G
# A1UdDgQWBBSIMw6eoo/3j5LPxP0WRheGAo+enzAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhCAQEEBAMC
# BBAwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwIwJTAjBggrBgEFBQcCARYXaHR0
# cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQBMEMGA1UdHwQ8MDowOKA2oDSG
# Mmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0Eu
# Y3JsMHMGCCsGAQUFBwEBBGcwZTA+BggrBgEFBQcwAoYyaHR0cDovL2NydC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdDQS5jcnQwIwYIKwYBBQUHMAGG
# F2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqGSIb3DQEBCwUAA4IBAQA4TZC2
# FTKk+hVV27NAKrP77xnHGgLLq2umsyoQSX5koT2hpSWhYwOtcp8UtCmfeXKpB2W9
# J+C9R9PGcIYwRJ+KyKOQZQJVMODq+qNHD7vjulE8brUEIshENVIv2YClYpqVGkg+
# SYSijIauqaX83vEfwk5C38sish5WjjTmklJPTDvqdXyzyGlMrmgSwrN/mP3Tdp9G
# DefyWd+rEuJDIzeH+2YY2ypYKAbWO058dyKsLlgeRLvPI0o3sq++k8O+ryKn+wXe
# +lT/x2dTMkx2uHH/N/rX7cRgS+wSvXcPTJKWvoEa1YSVrsRPc+RJwVHR3v2LAO+6
# 08oTB2eMy818gD7lMIIFgTCCBGmgAwIBAgIQOXJEOvkit1HX02wQ3TE1lTANBgkq
# hkiG9w0BAQwFADB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGlt
# aXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTE5MDMx
# MjAwMDAwMFoXDTI4MTIzMTIzNTk1OVowgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpOZXcgSmVyc2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhl
# IFVTRVJUUlVTVCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRp
# ZmljYXRpb24gQXV0aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAgBJlFzYOw9sIs9CsVw127c0n00ytUINh4qogTQktZAnczomfzD2p7PbPwdzx
# 07HWezcoEStH2jnGvDoZtF+mvX2do2NCtnbyqTsrkfjib9DsFiCQCT7i6HTJGLSR
# 1GJk23+jBvGIGGqQIjy8/hPwhxR79uQfjtTkUcYRZ0YIUcuGFFQ/vDP+fmyc/xad
# GL1RjjWmp2bIcmfbIWax1Jt4A8BQOujM8Ny8nkz+rwWWNR9XWrf/zvk9tyy29lTd
# yOcSOk2uTIq3XJq0tyA9yn8iNK5+O2hmAUTnAU5GU5szYPeUvlM3kHND8zLDU+/b
# qv50TmnHa4xgk97Exwzf4TKuzJM7UXiVZ4vuPVb+DNBpDxsP8yUmazNt925H+nND
# 5X4OpWaxKXwyhGNVicQNwZNUMBkTrNN9N6frXTpsNVzbQdcS2qlJC9/YgIoJk2KO
# tWbPJYjNhLixP6Q5D9kCnusSTJV882sFqV4Wg8y4Z+LoE53MW4LTTLPtW//e5XOs
# IzstAL81VXQJSdhJWBp/kjbmUZIO8yZ9HE0XvMnsQybQv0FfQKlERPSZ51eHnlAf
# V1SoPv10Yy+xUGUJ5lhCLkMaTLTwJUdZ+gQek9QmRkpQgbLevni3/GcV4clXhB4P
# Y9bpYrrWX1Uu6lzGKAgEJTm4Diup8kyXHAc/DVL17e8vgg8CAwEAAaOB8jCB7zAf
# BgNVHSMEGDAWgBSgEQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUU3m/Wqor
# Ss9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
# EQYDVR0gBAowCDAGBgRVHSAAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwu
# Y29tb2RvY2EuY29tL0FBQUNlcnRpZmljYXRlU2VydmljZXMuY3JsMDQGCCsGAQUF
# BwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0G
# CSqGSIb3DQEBDAUAA4IBAQAYh1HcdCE9nIrgJ7cz0C7M7PDmy14R3iJvm3WOnnL+
# 5Nb+qh+cli3vA0p+rvSNb3I8QzvAP+u431yqqcau8vzY7qN7Q/aGNnwU4M309z/+
# 3ri0ivCRlv79Q2R+/czSAaF9ffgZGclCKxO/WIu6pKJmBHaIkU4MiRTOok3JMrO6
# 6BQavHHxW/BBC5gACiIDEOUMsfnNkjcZ7Tvx5Dq2+UUTJnWvu6rvP3t3O9LEApE9
# GQDTF1w52z97GA1FzZOFli9d31kWTz9RvdVFGD/tSo7oBmF0Ixa1DVBzJ0RHfxBd
# iSprhTEUxOipakyAvGp4z7h/jnZymQyd/teRCBaho1+VMIIF9TCCA92gAwIBAgIQ
# HaJIMG+bJhjQguCWfTPTajANBgkqhkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYD
# VQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBS
# U0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgxMTAyMDAwMDAwWhcNMzAx
# MjMxMjM1OTU5WjB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQTCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBAIYijTKFehifSfCWL2MIHi3cfJ8Uz+Mm
# tiVmKUCGVEZ0MWLFEO2yhyemmcuVMMBW9aR1xqkOUGKlUZEQauBLYq798PgYrKf/
# 7i4zIPoMGYmobHutAMNhodxpZW0fbieW15dRhqb0J+V8aouVHltg1X7XFpKcAC9o
# 95ftanK+ODtj3o+/bkxBXRIgCFnoOc2P0tbPBrRXBbZOoT5Xax+YvMRi1hsLjcdm
# G0qfnYHEckC14l/vC0X/o84Xpi1VsLewvFRqnbyNVlPG8Lp5UEks9wO5/i9lNfIi
# 6iwHr0bZ+UYc3Ix8cSjz/qfGFN1VkW6KEQ3fBiSVfQ+noXw62oY1YdMCAwEAAaOC
# AWQwggFgMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bLMB0GA1UdDgQW
# BBQO4TqoUzox1Yq+wbutZxoDha00DjAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHSUEFjAUBggrBgEFBQcDAwYIKwYBBQUHAwgwEQYDVR0g
# BAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRy
# dXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2
# BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0
# LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0
# cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATWNQ7Uc0
# SmGk295qKoyb8QAAHh1iezrXMsL2s+Bjs/thAIiaG20QBwRPvrjqiXgi6w9G7PNG
# XkBGiRL0C3danCpBOvzW9Ovn9xWVM8Ohgyi33i/klPeFM4MtSkBIv5rCT0qxjyT0
# s4E307dksKYjalloUkJf/wTr4XRleQj1qZPea3FAmZa6ePG5yOLDCBaxq2NayBWA
# bXReSnV+pbjDbLXP30p5h1zHQE1jNfYw08+1Cg4LBH+gS667o6XQhACTPlNdNKUA
# NWlsvp8gJRANGftQkGG+OY96jk32nw4e/gdREmaDJhlIlc5KycF/8zoFm/lv34h/
# wCOe0h5DekUxwZxNqfBZslkZ6GqNKQQCd3xLS81wvjqyVVp4Pry7bwMQJXcVNIr5
# NsxDkuS6T/FikyglVyn7URnHoSVAaoRXxrKdsbwcCtp8Z359LukoTBh+xHsxQXGa
# SynsCz1XUNLK3f2eBVHlRHjdAd6xdZgNVCT98E7j4viDvXK6yz067vBeF5Jobchh
# +abxKgoLpbn0nu6YMgWFnuv5gynTxix9vTp3Los3QqBqgu07SqqUEKThDfgXxbZa
# eTMYkuO1dfih6Y4KJR7kHvGfWocj/5+kUZ77OYARzdu1xKeogG/lU9Tg46LC0lsa
# +jImLWpXcBw8pFguo/NbSwfcMlnzh6cabVgwggbsMIIE1KADAgECAhAwD2+s3WaY
# dHypRjaneC25MA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xOTA1MDIwMDAwMDBaFw0zODAxMTgyMzU5
# NTlaMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIx
# EDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMG
# A1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAMgbAa/ZLH6ImX0BmD8gkL2cgCFUk7nPoD5T77Na
# wHbWGgSlzkeDtevEzEk0y/NFZbn5p2QWJgn71TJSeS7JY8ITm7aGPwEFkmZvIavV
# cRB5h/RGKs3EWsnb111JTXJWD9zJ41OYOioe/M5YSdO/8zm7uaQjQqzQFcN/nqJc
# 1zjxFrJw06PE37PFcqwuCnf8DZRSt/wflXMkPQEovA8NT7ORAY5unSd1VdEXOzQh
# e5cBlK9/gM/REQpXhMl/VuC9RpyCvpSdv7QgsGB+uE31DT/b0OqFjIpWcdEtlEzI
# jDzTFKKcvSb/01Mgx2Bpm1gKVPQF5/0xrPnIhRfHuCkZpCkvRuPd25Ffnz82Pg4w
# ZytGtzWvlr7aTGDMqLufDRTUGMQwmHSCIc9iVrUhcxIe/arKCFiHd6QV6xlV/9A5
# VC0m7kUaOm/N14Tw1/AoxU9kgwLU++Le8bwCKPRt2ieKBtKWh97oaw7wW33pdmmT
# IBxKlyx3GSuTlZicl57rjsF4VsZEJd8GEpoGLZ8DXv2DolNnyrH6jaFkyYiSWcuo
# RsDJ8qb/fVfbEnb6ikEk1Bv8cqUUotStQxykSYtBORQDHin6G6UirqXDTYLQjdpr
# t9v3GEBXc/Bxo/tKfUU2wfeNgvq5yQ1TgH36tjlYMu9vGFCJ10+dM70atZ2h3pVB
# eqeDAgMBAAGjggFaMIIBVjAfBgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNm
# yzAdBgNVHQ4EFgQUGqH4YRkgD8NBd0UojtE1XwYSBFUwDgYDVR0PAQH/BAQDAgGG
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwEQYDVR0g
# BAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRy
# dXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2
# BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0
# LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0
# cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAbVSBpTNd
# FuG1U4GRdd8DejILLSWEEbKw2yp9KgX1vDsn9FqguUlZkClsYcu1UNviffmfAO9A
# w63T4uRW+VhBz/FC5RB9/7B0H4/GXAn5M17qoBwmWFzztBEP1dXD4rzVWHi/SHbh
# RGdtj7BDEA+N5Pk4Yr8TAcWFo0zFzLJTMJWk1vSWVgi4zVx/AZa+clJqO0I3fBZ4
# OZOTlJux3LJtQW1nzclvkD1/RXLBGyPWwlWEZuSzxWYG9vPWS16toytCiiGS/qhv
# WiVwYoFzY16gu9jc10rTPa+DBjgSHSSHLeT8AtY+dwS8BDa153fLnC6NIxi5o8JH
# HfBd1qFzVwVomqfJN2Udvuq82EKDQwWli6YJ/9GhlKZOqj0J9QVst9JkWtgqIsJL
# nfE5XkzeSD2bNJaaCV+O/fexUpHOP4n2HKG1qXUfcb9bQ11lPVCBbqvw0NP8srMf
# tpmWJvQ8eYtcZMzN7iea5aDADHKHwW5NWtMe6vBE5jJvHOsXTpTDeGUgOw9Bqh/p
# oUGd/rG4oGUqNODeqPk85sEwu8CgYyz8XBYAqNDEf+oRnR4GxqZtMl20OAkrSQeq
# /eww2vGnL8+3/frQo4TZJ577AWZ3uVYQ4SBuxq6x+ba6yDVdM3aO8XwgDCp3rrWi
# Aoa6Ke60WgCxjKvj+QrJVF3UuWp0nr1Irpgwggb2MIIE3qADAgECAhEAkDl/mtJK
# OhPyvZFfCDipQzANBgkqhkiG9w0BAQwFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3Rh
# bXBpbmcgQ0EwHhcNMjIwNTExMDAwMDAwWhcNMzMwODEwMjM1OTU5WjBqMQswCQYD
# VQQGEwJHQjETMBEGA1UECBMKTWFuY2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBM
# aW1pdGVkMSwwKgYDVQQDDCNTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25l
# ciAjMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJCycT954dS5ihfM
# w5fCkJRy7Vo6bwFDf3NaKJ8kfKA1QAb6lK8KoYO2E+RLFQZeaoogNHF7uyWtP1sK
# pB8vbH0uYVHQjFk3PqZd8R5dgLbYH2DjzRJqiB/G/hjLk0NWesfOA9YAZChWIrFL
# GdLwlslEHzldnLCW7VpJjX5y5ENrf8mgP2xKrdUAT70KuIPFvZgsB3YBcEXew/BC
# aer/JswDRB8WKOFqdLacRfq2Os6U0R+9jGWq/fzDPOgNnDhm1fx9HptZjJFaQldV
# UBYNS3Ry7qAqMfwmAjT5ZBtZ/eM61Oi4QSl0AT8N4BN3KxE8+z3N0Ofhl1tV9yoD
# bdXNYtrOnB786nB95n1LaM5aKWHToFwls6UnaKNY/fUta8pfZMdrKAzarHhB3pLv
# D8Xsq98tbxpUUWwzs41ZYOff6Bcio3lBYs/8e/OS2q7gPE8PWsxu3x+8Iq+3OBCa
# NKcL//4dXqTz7hY4Kz+sdpRBnWQd+oD9AOH++DrUw167aU1ymeXxMi1R+mGtTeom
# jm38qUiYPvJGDWmxt270BdtBBcYYwFDk+K3+rGNhR5G8RrVGU2zF9OGGJ5OEOWx1
# 4B0MelmLLsv0ZCxCR/RUWIU35cdpp9Ili5a/xq3gvbE39x/fQnuq6xzp6z1a3fjS
# kNVJmjodgxpXfxwBws4cfcz7lhXFAgMBAAGjggGCMIIBfjAfBgNVHSMEGDAWgBQa
# ofhhGSAPw0F3RSiO0TVfBhIEVTAdBgNVHQ4EFgQUJS5oPGuaKyQUqR+i3yY6zxSm
# 8eAwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYI
# KwYBBQUHAwgwSgYDVR0gBEMwQTA1BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcC
# ARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQQCMEQGA1UdHwQ9MDsw
# OaA3oDWGM2h0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFt
# cGluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6Ly9j
# cnQuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNydDAjBggr
# BgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQAD
# ggIBAHPa7Whyy8K5QKExu7QDoy0UeyTntFsVfajp/a3Rkg18PTagadnzmjDarGnW
# dFckP34PPNn1w3klbCbojWiTzvF3iTl/qAQF2jTDFOqfCFSr/8R+lmwr05TrtGzg
# RU0ssvc7O1q1wfvXiXVtmHJy9vcHKPPTstDrGb4VLHjvzUWgAOT4BHa7V8WQvndU
# kHSeC09NxKoTj5evATUry5sReOny+YkEPE7jghJi67REDHVBwg80uIidyCLxE2rb
# GC9ueK3EBbTohAiTB/l9g/5omDTkd+WxzoyUbNsDbSgFR36bLvBk+9ukAzEQfBr7
# PBmA0QtwuVVfR745ZM632iNUMuNGsjLY0imGyRVdgJWvAvu00S6dOHw14A8c7RtH
# SJwialWC2fK6CGUD5fEp80iKCQFMpnnyorYamZTrlyjhvn0boXztVoCm9CIzkOSE
# U/wq+sCnl6jqtY16zuTgS6Ezqwt2oNVpFreOZr9f+h/EqH+noUgUkQ2C/L1Nme3J
# 5mw2/ndDmbhpLXxhL+2jsEn+W75pJJH/k/xXaZJL2QU/bYZy06LQwGTSOkLBGgP7
# 0O2aIbg/r6ayUVTVTMXKHxKNV8Y57Vz/7J8mdq1kZmfoqjDg0q23fbFqQSduA4qj
# dOCKCYJuv+P2t7yeCykYaIGhnD9uFllLFAkJmuauv2AV3Yb1MYIFgzCCBX8CAQEw
# gZEwfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQ
# MA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYD
# VQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0ECEQDLfPNQC5p3ocmlVHGE
# Wq2zMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBRe2yPNoMS+Gpxv0LTawirF7J/1ADANBgkqhkiG
# 9w0BAQEFAASCAQAijjgZUV1PaDSSdz0QDqnMTGaPHi7yGmRe/v5xCsRGwBedv2lk
# Oxro+ofKpkVRkHsjHiA2uMtskWdPaIg0+Y3oNVSCjRj5c6GKY3Xqovd5A7HNitvW
# cwCiIiMSu22IvJ00jxdN9radYx9HBuO8Cj+Tu1oAEGmY7UsOx6aLx/jfh5aOTTj/
# HBeD4MEXPXth5+nRkQUOUg/iolDMZQ60tkZQDNO5SuWlF9zOxcOjff2SkVtr/pYV
# 6eCd+aWVdQ0758z5C2ht5ZRHMeTskYl4gvG4Da2fuRnctRK++clWLy5uxlAz1ZcS
# L/EkK3Y4jTE79mzJkiOcN1Qy7TnRCe+1EhyLoYIDTDCCA0gGCSqGSIb3DQEJBjGC
# AzkwggM1AgEBMIGSMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1h
# bmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGlt
# aXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFtcGluZyBDQQIRAJA5
# f5rSSjoT8r2RXwg4qUMwDQYJYIZIAWUDBAICBQCgeTAYBgkqhkiG9w0BCQMxCwYJ
# KoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMjA4MjcxOTQyMDRaMD8GCSqGSIb3
# DQEJBDEyBDAAywS95WTSQgPWU9nw6iSTvb53eWSJNYzYyrIO925j2sFcENTnyzHE
# jC5ID3Hd9aAwDQYJKoZIhvcNAQEBBQAEggIAQd7qEzFMMiRgruXiViAlZiWZcPiX
# Amxrp9xay+VLAHmzYnHwvdcKJ3nOCH+VAjx1tn3RNHvkEg02MTyKsKG3ITJGfRt5
# OMc43OAj6+ABDfZ1G/AgWAd2KmJp5Ob9TJwi/1GevmMTZtJBwh8VOc8EOOFbD9Mq
# qySbttQPYJ8EMfT4TkoCiYB6oo5K5ZHMX0tDvptwEcrbfAEaM2tcqEn3zNa3XPlT
# w5AHiTMgOtxfSpP/qgCjq+TvUI+Xu9YVtOBPOZneLSt1Dq4WMOzAD0IBAz+Eae+v
# thdeH6+2xveY6JKiw0wDaIkht+IP6lISAG1jVggTFuzs74rC1w4jWUDT/7PD4w5w
# rbPSPvA8HOFfD5v0RsCQXZp6A7BYqQwar+dHgX7wyx7L2IsIo4WSLxifMWRNA8L6
# BHFg5qnXJdcRRcvVPvCXCyI8ltTvezS/bavJErB5c6ibyL4AM4VqM4rpkSGnURg1
# SFVk4QoIDbrqprfg1MD3pvJU6+EnfH57MrFkYm5EEamq6bOYEmNBDLs4yVqgpIPc
# 6tOomEeQ1Id6HfeCU8dn/FJBxmpuSbd5pcco0lh3y8pl3VP/1wfCs5xCfCK6A7Ts
# x3NI9YYMaPUPHsl+5c5C58aLbOdL7RjMEYCIpa4+uOfUBCoJpbEF6p9zOje7n18V
# 7HkmO0cF96a2buU=
# SIG # End signature block

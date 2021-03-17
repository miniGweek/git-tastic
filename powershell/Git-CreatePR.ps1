# Referenced https://dev.to/omiossec/getting-started-with-azure-devops-api-with-powershell-59nn
# Referenced https://docs.microsoft.com/en-us/rest/api/azure/devops/git/pull%20requests/create?view=azure-devops-rest-6.0
function Git-CreatePR([string]$currentBranch , [string]$targetBranch = "master", [string]$t, [string]$d) {
    $description = $d;
    $title = $t;
    $AzureDevOpsPAT = $env:MYVAR_AZUREDEVOPSPAT;    
    $organization = $env:MYVAR_ORGANIZATION;
    $project = $env:MYVAR_PROJECT
    $repositoryName = $env:MYVAR_REPOSITORYNAME
    $repositoryId = $env:MYVAR_REPOSITORYID
    if ($currentBranch -eq "") {
        $currentBranch = git branch --show-current;
    }
    # Write-Host $currentBranch
    $commitMsg = git log -1 --oneline $(git branch --show-current);
    $lastCommitHash = git rev-parse --short HEAD
    if ($title -eq "") {
        $title = $commitMsg.Split($lastCommitHash)[1]
    }
    # Write-Host $title
    if ($description -eq "") {
        $description = $title
    }
    # Write-Host $description

    $AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }    

    # $UriOrga = "https://dev.azure.com/$($OrganizationName)/" 
    # $uriAccount = $UriOrga + "_apis/projects?api-version=5.1"
    $PRUri = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/pullrequests?api-version=6.0"
    # Write-Host $PRUri

    $requestBody = @"
{
    "sourceRefName": "refs/heads/$currentBranch",
    "targetRefName": "refs/heads/$targetBranch",
    "title":"$title",
    "description":"$description"
  }
"@
    # Write-Host $requestBody;
    #$result = Invoke-RestMethod -Uri $PRUri -Method Post -Headers $AzureDevOpsAuthenicationHeader  -ContentType "application/json" -Body $requestBody
    $jsonResponse = Invoke-WebRequest -Uri $PRUri -Method Post -Headers $AzureDevOpsAuthenicationHeader -ContentType "application/json" -Body $requestBody
    
    $result = ConvertFrom-Json($jsonResponse);

    $shortResult = [ordered]@{title = $result.title; 
        description                 = $result.description; 
        pullRequestId               = $result.pullRequestId; 
        status                      = $result.status; 
        creationDate                = $result.creationDate;         
        sourceRefName               = $result.sourceRefName;
        targetRefName               = $result.targetRefName;
        url                         = $result.url;
    };
    return $shortResult;
}
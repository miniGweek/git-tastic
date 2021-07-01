# Referenced https://dev.to/omiossec/getting-started-with-azure-devops-api-with-powershell-59nn
# Referenced https://docs.microsoft.com/en-us/rest/api/azure/devops/git/pull%20requests/create?view=azure-devops-rest-6.0
function Git-CreatePR([string]$currentBranch , [string]$targetBranch = "master", [string]$t, [string]$d) {
    $description = $d;
    $title = $t;
    $AzureDevOpsPAT = $env:MYVAR_AZUREDEVOPSPAT;    
    $organization = $env:MYVAR_ORGANIZATION;
    $project = $env:MYVAR_PROJECT
    $repositoryId = $env:MYVAR_REPOSITORYID
    if ($currentBranch -eq "") {
        $currentBranch = git branch --show-current;
    }

    $commitMsg = git log -1 --oneline $(git branch --show-current);
    $lastCommitHash = git rev-parse --short HEAD
    if ($title -eq "") {
        $title = $commitMsg.Split($lastCommitHash)[1]
    }

    if ($description -eq "") {
        $description = $title
    }


    $AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }    
    $PRRepositoryUri = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId";
    $PRUri = "$PRRepositoryUri/pullrequests?api-version=6.0"

    $requestBody = @"
{
    "sourceRefName": "refs/heads/$currentBranch",
    "targetRefName": "refs/heads/$targetBranch",
    "title":"$title",
    "description":"$description"
  }
"@
    #Write-Host $requestBody;
    Write-Host "###... Creating the Pull Request ..."
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

    Write-Host "###... Setting the Auto Complete options on the Pull Request #$($shortResult.pullRequestId) ..."

    Set-PullRequestCompleteOptions -PRRepositoryUri $PRRepositoryUri -PullRequestId $shortResult.pullRequestId  -TokenHeader $AzureDevOpsAuthenicationHeader -title $title
    return $shortResult;
}

Function Set-PullRequestCompleteOptions($PRRepositoryUri, $PullRequestId, $TokenHeader, $title) {
    Write-Host "###... Initiating Update of Pullrequest #$PullRequestId ..."

    $requestBody = @"
    {
        "autoCompleteSetBy": {
            "id": "992a50f9-fabd-6450-8170-52f580f66340"
        },
        "completionOptions" : {
            "deleteSourceBranch":"true",
            "squashMerge":"true",
            "mergeStrategy":"squash",
            "mergeCommitMessage" :"Merged PR $PullRequestId`:$title",
        }
    }
"@

    $UpdatePRUri = "$PRRepositoryUri/pullrequests/$PullRequestId`?api-version=6.0"

    Write-Host "###... Update Pull Request Uri - $UpdatePRUri ..."
    Write-Host "###... PATCH request body: ..."
    Write-Host $requestBody
    Write-Host "###... End of PATCH request body: ..."
    $jsonResponse = Invoke-WebRequest -Uri $UpdatePRUri -Method PATCH -Headers $TokenHeader -ContentType "application/json" -Body $requestBody
    Write-Host "###... Updated Pullrequest #$PullRequestId ..."
}
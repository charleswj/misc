function Set-CWJFileSensitivityLabel
{
    param(
        [Parameter(Mandatory)]
        [guid]
        $SiteId,
        
        [Parameter(Mandatory)]
        [string]
        $DriveId,
        
        [Parameter(Mandatory)]
        [string]
        $FileId,

        [Parameter(Mandatory)]
        [ValidateScript({[bool]$(try{[guid]$_}catch{}) -or $_ -eq ''})]
        [AllowEmptyString()]
        [string]
        $LabelId,

        # 7fff6936-455f-4307-b66d-378f7866d130 # SSAN Label
        # 3bdff4f9-6b25-420f-a673-be8db82cb968 # HEADERFOOTERWATERMARK

        [string]
        $Justification
    )

    $url = '/_api/v2.1/sites/{0}/drives/{1}/items/{2}/setSensitivityLabel' -f $SiteId, $DriveId, $FileId

    $body = @{
        id                = $LabelId
        assignmentMethod  = 'Privileged'
        justificationText = $Justification
        actionSource      = 'Manual'
    }

    $InvokePnPSPRestMethodParams = @{
        Url     = $url
        Method  = 'Post'
        Content = $body
    }
    
    Invoke-PnPSPRestMethod @InvokePnPSPRestMethodParams
}





$site = Invoke-PnPGraphMethod -Url '/v1.0/sites/m365x44936036.sharepoint.com:/'

#drive aka library
$library = Invoke-PnPGraphMethod -Url ('/v1.0/sites/{0}/drives' -f $site.id) | % value | ? name -eq testlibrary

$relativePath = 'emptyDocFiles10'

if($relativePath.Length -gt 0)
{
    $relativePath = ':/' + $relativePath + ':'
}
else
{
    $relativePath = ''
}

$children = Invoke-PnPGraphMethod -Url ('/v1.0/sites/{0}/drives/{1}/items/root{2}/children?$select=parentReference,id,file,name' -f $site.id, $library.id, $relativePath) | % value

$files = $children | ? file

foreach($file in $files)
{
    Write-Warning $file.name

    $SetCWJFileSensitivityLabelParams = @{
        SiteId  = $file.parentReference.siteId
        DriveId = $file.parentReference.driveId
        FileId  = $file.id

        # LabelId = '7fff6936-455f-4307-b66d-378f7866d130' # SSAN Label
        # LabelId = '3bdff4f9-6b25-420f-a673-be8db82cb968' # HEADERFOOTERWATERMARK
        LabelId = $null
    }

    Set-CWJFileSensitivityLabel @SetCWJFileSensitivityLabelParams
}

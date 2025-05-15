
#############################################################################
# DELETE ANY TESTAPI CASES

$InvokeMgGraphRequestParams = @{
    Method = 'GET'
    Uri    = 'v1.0/security/cases/ediscoveryCases?$filter=startswith(displayName, ''testApi'')'
}

$ediscoveryCases = Invoke-MgGraphRequest @InvokeMgGraphRequestParams | % value

$ediscoveryCases | %{
    Write-Warning ('Deleting case {0} {1}' -f $_.Item('id'), $_.Item('displayName'))
    $InvokeMgGraphRequestParams = @{
        Method = 'DELETE'
        Uri    = 'v1.0/security/cases/ediscoveryCases/{0}' -f $_.Item('id')
    }
    
    $ediscoveryCases = Invoke-MgGraphRequest @InvokeMgGraphRequestParams | % value
}

#############################################################################





Write-Warning ''

$timestamp = get-date -Format yyyyMMddHHmmss





#############################################################################
# CREATE CASE

$InvokeMgGraphRequestParams = @{
    Method = 'POST'
    Uri    = 'v1.0/security/cases/ediscoveryCases'
    Body   = @{
        displayName = 'testApi-EdiscoveryCase-DisplayName-{0}' -f $timestamp
        description = 'testApi-EdiscoveryCase-Description-{0}' -f $timestamp
        externalId  = 'testApi-EdiscoveryCase-ExternalId-{0}'  -f $timestamp
        createdBy = @{
            user = @{
                id                = 'fc18a8b6-c58d-42dc-af05-ef48953f7e84'
                displayName       = 'admin'
                userPrincipalName = 'admin@motherchucker.com'
            }
        }
    } | ConvertTo-Json
}

$global:ediscoveryCase = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

Write-Warning ('Created case {0} {1}' -f $ediscoveryCase.Item('id'), $ediscoveryCase.Item('displayName'))

#############################################################################





#############################################################################
# CREATE CUSTODIANS

$custodianSources = @()

'admin@motherchucker.com','AdeleV@m365x44936036.onmicrosoft.com' | % {

    # create the custodian
    $InvokeMgGraphRequestParams = @{
        Method = 'POST'
        Uri    = 'v1.0/security/cases/ediscoveryCases/{0}/custodians' -f $ediscoveryCase.Item('id')
        Body   = @{
            email = $_
        } | ConvertTo-Json
    }

    $ediscoveryCaseCustodian = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

    Write-Warning ('    Created custodian {0} {1}' -f $ediscoveryCaseCustodian.Item('id'), $ediscoveryCaseCustodian.Item('email'))





    # create the custodian user source 
    $InvokeMgGraphRequestParams = @{
        Method = 'POST'
        Uri    = 'v1.0/security/cases/ediscoveryCases/{0}/custodians/{1}/userSources' -f $ediscoveryCase.Item('id'), $ediscoveryCaseCustodian.Item('id')
        Body   = @{
            email           = $ediscoveryCaseCustodian.Item('email')
            includedSources = 'mailbox' # mailbox, site
        } | ConvertTo-Json
    }

    $ediscoveryCaseCustodianUserSource = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

    Write-Warning ('        Created custodian user source {0} {1}' -f $ediscoveryCaseCustodianUserSource.Item('id'), $ediscoveryCaseCustodianUserSource.Item('email'))

    $custodianSource = 'https://graph.microsoft.com/v1.0/security/cases/ediscoveryCases/{0}/custodians/{1}/userSources/{2}' -f $ediscoveryCase.Item('id'), $ediscoveryCaseCustodian.Item('id'), $ediscoveryCaseCustodianUserSource.Item('id')
    #TODO don't hardcode URI
    $custodianSources += $custodianSource

    Write-Warning ('        {0}' -f $custodianSources)

}

#############################################################################





#############################################################################
# CREATE SEARCH

$InvokeMgGraphRequestParams = @{
    Method = 'POST'
    Uri    = 'v1.0/security/cases/ediscoveryCases/{0}/searches' -f $ediscoveryCase.Item('id')
    Body   = @{
        displayName      = 'testApi-ediscoveryCase-Search-DisplayName-{0}' -f $timestamp
        description      = 'testApi-ediscoveryCase-Search-Description-{0}' -f $timestamp
        # contentQuery1     = '("blah")'
        contentQuery     = '(Author="edison")'
        #TODO why doesn't the query show in preview, and why only raw KeyQL? seems to not be a premium case???
        # dataSourceScopes = 'allTenantMailboxes'
        'custodianSources@odata.bind' = $custodianSources
        createdBy = @{
            user = @{
                id                = 'fc18a8b6-c58d-42dc-af05-ef48953f7e84'
                displayName       = 'admin'
                userPrincipalName = 'admin@motherchucker.com'
            }
        }
    } | ConvertTo-Json
}

$global:ediscoveryCaseSearch = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

#############################################################################






# #############################################################################
# # EXPORT REPORT

# $InvokeMgGraphRequestParams = @{
#     Method = 'POST'
#     #beta seems required, v1.0 returns HTTP500 InternalServerError, An unexpected error occurred
#     Uri    = 'beta/security/cases/ediscoveryCases/{0}/searches/{1}/exportReport' -f $ediscoveryCase.Item('id'), $ediscoveryCaseSearch.Item('id')
#     Body   = @{
#         additionalOptions = 'none'
#         displayName       = 'testApi-ediscoveryCase-Search-exportReport-DisplayName-{0}' -f $timestamp
#         # description       = 'testApi-ediscoveryCase-Search-exportReport-Description-{0}' -f $timestamp
#         exportCriteria    = 'searchHits'
#         # exportLocation    = 'responsiveLocations'
#     } | ConvertTo-Json
# }

# $global:ediscoveryCaseSearchExportreport = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

# #############################################################################




# #############################################################################
# # estimateStatistics

# $InvokeMgGraphRequestParams = @{
#     Method = 'POST'
#     Uri    = 'v1.0/security/cases/ediscoveryCases/{0}/searches/{1}/exportReport' -f $ediscoveryCase.Item('id'), $ediscoveryCaseSearch.Item('id')
#     Body   = @{
#         additionalOptions = 'none'
#         displayName       = 'testApi-ediscoveryCase-Search-exportReport-DisplayName-{0}' -f $timestamp
#         # description       = 'testApi-ediscoveryCase-Search-exportReport-Description-{0}' -f $timestamp
#         exportCriteria    = 'searchHits'
#         # exportLocation    = 'responsiveLocations'
#     } | ConvertTo-Json
# }

# $global:ediscoveryCaseSearchExportreport = Invoke-MgGraphRequest @InvokeMgGraphRequestParams

# #############################################################################



     
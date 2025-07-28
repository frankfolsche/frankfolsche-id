# The error indicates the application is missing a service principal in the target tenant.
# To resolve, ensure the app registration exists in Azure AD and create a service principal for it.

# Pseudocode:
# 1. Check if the service principal exists for the given ClientId.
# 2. If not, create the service principal.
# 3. Proceed with token acquisition and flow deployment.

$ErrorActionPreference = 'Stop'

$tenantId = $env:TENANT_ID
$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET
Write-Host $tenantId
Write-Host $clientId

$details = @{
    'TenantId'     = $tenantId
    'ClientId'     = $clientId
    'ClientSecret' = $clientSecret | ConvertTo-SecureString -AsPlainText -Force
}
$token = Get-MsalToken @details
Connect-MgGraph -AccessToken ($token.AccessToken | ConvertTo-SecureString -AsPlainText -Force) -Scopes "EventListener.ReadWrite.All Application.ReadWrite.All"

# Define the External ID flow payload (customize as needed)
$params =  @{
    "@odata.type" = "#microsoft.graph.externalUsersSelfServiceSignUpEventsFlow"
    displayName = "Default sign-up and sign-in"
    description = "Woodgrove default sign-up and sign-in flow"
    priority = 500
    conditions =  @{
        applications =  @{
            includeAllApplications = $false
        }
    }
    onInteractiveAuthFlowStart =  @{
        "@odata.type" = "#microsoft.graph.onInteractiveAuthFlowStartExternalUsersSelfServiceSignUp"
        isSignUpAllowed = $true
    }
    onAuthenticationMethodLoadStart =  @{
        "@odata.type" = "#microsoft.graph.onAuthenticationMethodLoadStartExternalUsersSelfServiceSignUp"
        identityProviders =  @(
             @{
                "@odata.type" = "#microsoft.graph.builtInIdentityProvider"
                id = "EmailPassword-OAUTH"
            }
        )
    }
    onAttributeCollection =  @{
        "@odata.type" = "#microsoft.graph.onAttributeCollectionExternalUsersSelfServiceSignUp"
        accessPackages =  @()
        attributeCollectionPage =  @{
            customStringsFileId =  $undefinedVariable
            views =  @(
                 @{
                    title =  $undefinedVariable
                    description =  $undefinedVariable
                    inputs =  @(
                         @{
                            attribute = "email"
                            label = "Email Address"
                            inputType = "text"
                            defaultValue =  $undefinedVariable
                            hidden = $true
                            editable = $false
                            writeToDirectory = $true
                            required = $true
                            validationRegEx = "^[a-zA-Z_][0-9a-zA-Z_ ]*[0-9a-zA-Z_]+$"
                            options =  @()
                        }
                         @{
                            attribute = "displayName"
                            label = "Display Name"
                            inputType = "text"
                            defaultValue =  $undefinedVariable
                            hidden = $false
                            editable = $true
                            writeToDirectory = $true
                            required = $true
                            validationRegEx = "^.*"
                            options =  @()
                        }
                         @{
                            attribute = "country"
                            label = "Country/Region"
                            inputType = "radioSingleSelect"
                            defaultValue =  $undefinedVariable
                            hidden = $false
                            editable = $true
                            writeToDirectory = $true
                            required = $false
                            validationRegEx = "^.*"
                            options =  @(
                                 @{
                                    label = "Australia"
                                    value = "au"
                                }
                                 @{
                                    label = "Spain"
                                    value = "es"
                                }
                                 @{
                                    label = "United States"
                                    value = "us"
                                }
                            )
                        }
                         @{
                            attribute = "city"
                            label = "City"
                            inputType = "text"
                            defaultValue =  $undefinedVariable
                            hidden = $false
                            editable = $true
                            writeToDirectory = $true
                            required = $false
                            validationRegEx = "^.*"
                            options =  @()
                        }
                    )
                }
            )
        }
        attributes =  @(
             @{
                id = "email"
            }
             @{
                id = "city"
            }
             @{
                id = "country"
            }
             @{
                id = "displayName"
            }
        )
    }
    onUserCreateStart =  @{
        "@odata.type" = "#microsoft.graph.onUserCreateStartExternalUsersSelfServiceSignUp"
        userTypeToCreate = "member"
        accessPackages =  @()
    }
}

# Deploy the External ID flow using Microsoft Graph API
New-MgBetaIdentityAuthenticationEventFlow -BodyParameter $params

# Optionally, output the result

# Define the External ID flow payload
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

# Check if the External ID flow exists
$existingFlow = Get-MgBetaIdentityAuthenticationEventFlow | Where-Object { $_.displayName -eq "Default sign-up and sign-in" }

if ($null -eq $existingFlow) {
    # Create new flow if it doesn't exist
    New-MgBetaIdentityAuthenticationEventFlow -BodyParameter $params
}


$params =  @{
    id = "0"
    backgroundColor = "#3498DB"
    signInPageText = "Welcome to Azure Fest"
}

Update-MgOrganizationBrandingLocalization -OrganizationId $env:TenantId -OrganizationalBrandingLocalizationId 0 -BodyParameter $params
<#
    .SYNOPSIS
        Deploy a Terraform landing zone or apply a blueprint.

    .DESCRIPTION
        This command will prepare a Terraform landing zone or
        apply a blueprint.

    .PARAMETER Blueprint
        The path to the folder containing the blueprint to apply.

    .PARAMETER Action
        The Terraform action to use with the blueprint.

    .PARAMETER Command
        The Terraform command to use with the blueprint.

    .EXAMPLE
        C:\> launchpad.ps1

        Deploy the landing zone environment.

    .EXAMPLE
        C:\> launchpad.ps1 -Blueprint blueprint_tranquility -Action apply

        Apply the 'blueprint_tranquility'.
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $Blueprint,

    [Parameter()]
    [System.String]
    $Action,

    [Parameter()]
    [System.String]
    $Command
)

$ErrorActionPreference = 'Stop'

Push-Location

Write-Verbose -Message "Calling Launchpad with Action: '$Action', Command: '$Command', Blueprint: '$Blueprint'"

$launchPad = Get-LaunchPad

if ($launchPad)
{
    Write-Verbose -Message 'Launchpad initialized and ready.'
}
else
{
    Write-Verbose -Message 'Launchpad is not initialized.'
    $launchPad = New-Launchpad
}


# Initialise storage account to store remote terraform state
if [ "$id" == "null" ]; then
        echo "Calling initialize_state"
        blueprint_name="level0_launchpad"

        initialize_state

        id=$(az resource list --tag stgtfstate=level0 | jq -r .[0].id)

        echo "Launchpad initialized and ready"
        get_remote_state_details
else    
        echo ""
        echo "Launchpad already initialized."
        get_remote_state_details
        echo ""

        if [ -z "${blueprint_name}" ]; then 
                display_instructions
                exit 1
        fi
fi

if [ "${blueprint_name}" == "level0_launchpad" ]; then

        if [ "${tf_action}" == "destroy" ]; then
                echo "The moon launchpad is protected from deletion"
        fi

        display_instructions
else
        echo "Deploying '${blueprint_name}'"

        cd ${blueprint_name}

        tf_name="${blueprint_name}.tfstate"

        # Get parameters of the terraform state from keyvault. Note we are using tags to retrieve the level0
        export keyvault=$(az resource list --tag kvtfstate=level0 | jq -r .[0].name) && echo " - keyvault_name: ${keyvault}"

        # Set the security context under the devops app
        echo ""
        echo "Identity of the pilot in charge of delivering the landing zone"
        export ARM_SUBSCRIPTION_ID=$(az keyvault secret show -n tfstate-sp-devops-subscription-id --vault-name ${keyvault} | jq -r .value) && echo " - subscription id: ${ARM_SUBSCRIPTION_ID}"
        export ARM_CLIENT_ID=$(az keyvault secret show -n tfstate-sp-devops-client-id --vault-name ${keyvault} | jq -r .value) && echo " - client id: ${ARM_CLIENT_ID}"
        export ARM_CLIENT_SECRET=$(az keyvault secret show -n tfstate-sp-devops-client-secret --vault-name ${keyvault} | jq -r .value)
        export ARM_TENANT_ID=$(az keyvault secret show -n tfstate-sp-devops-tenant-id --vault-name ${keyvault} | jq -r .value) && echo " - tenant id: ${ARM_TENANT_ID}"
 
        export TF_VAR_prefix=$(az keyvault secret show -n tfstate-prefix --vault-name ${keyvault} | jq -r .value)
        echo ""
        export TF_VAR_lowerlevel_storage_account_name=$(az keyvault secret show -n tfstate-storage-account-name --vault-name ${keyvault} | jq -r .value)
        export TF_VAR_lowerlevel_resource_group_name=$(az keyvault secret show -n tfstate-resource-group --vault-name ${keyvault} | jq -r .value)
        export TF_VAR_lowerlevel_key=$(az keyvault secret show -n tfstate-blob-name --vault-name ${keyvault} | jq -r .value)
        export TF_VAR_lowerlevel_container_name=$(az keyvault secret show -n tfstate-container --vault-name ${keyvault} | jq -r .value)
        
        # todo to be replaced with SAS key - short ttl or msi with the rover
        export ARM_ACCESS_KEY=$(az storage account keys list --account-name ${storage_account_name} --resource-group ${resource_group} | jq -r .[0].value)

        terraform init \
                -reconfigure \
                -backend=true \
                -lock=false \
                -backend-config storage_account_name=${storage_account_name} \
                -backend-config container_name=${container} \
                -backend-config access_key=${access_key} \
                -backend-config key=${tf_name}

        if [ ${tf_action} == "plan" ]; then
                echo "calling plan"
                plan
        fi

        if [ ${tf_action} == "apply" ]; then
                echo "calling plan and apply"
                plan
                apply
        fi

        if [ ${tf_action} == "destroy" ]; then
                echo "calling destroy"
                destroy
        fi

        if [ -f ${blueprint_name}.tfplan ]; then
                echo "Deleting file ${blueprint_name}.tfplan"
                rm ${blueprint_name}.tfplan
        fi

        cd "${current_path}"
fi

function initialize_state {
        echo "Initializing launchpad from ${blueprint_name}"
        cd ${blueprint_name}
        set +e
        rm ./.terraform/terraform.tfstate
        rm ./terraform.tfstate
        rm backend.azurerm.tf
        set -e

        # Get the looged in user ObjectID
        export TF_VAR_logged_user_objectId=$(az ad signed-in-user show --query objectId -o tsv)

        terraform init
        terraform apply -auto-approve

        echo ""
        upload_tfstate

        cd "${current_path}"
}

function initialize_from_remote_state {
        echo 'Connecting to the launchpad'
        cd ${blueprint_name}
        cp backend.azurerm backend.azurerm.tf
        tf_name="${blueprint_name}.tfstate"

        terraform init \
                -backend=true \
                -reconfigure=true \
                -upgrade=true \
                -backend-config storage_account_name=${storage_account_name} \
                -backend-config container_name=${container} \
                -backend-config access_key=${access_key} \
                -backend-config key=${tf_name}


        terraform apply -refresh=true -auto-approve

        rm backend.azurerm.tf
        cd "${current_path}"
}

function plan {
        echo "running terraform plan with $tf_command"
        terraform plan $tf_command \
                -refresh=true \
                -out=${blueprint_name}.tfplan
}

function apply {
        echo 'running terraform apply'
        terraform apply \
                -no-color \
                ${blueprint_name}.tfplan
        
        cd "${current_path}"
}

function destroy {
        echo 'running terraform destroy'
        terraform destroy ${tf_command} \
                -refresh=true
}


function deploy_blueprint {
        cd ${blueprint_name}
        export TF_VAR_tfstate_current_level=$(terraform output tfstate_map)
        export TF_VAR_deployment_msi=$(terraform output deployment_msi)
        export TF_VAR_keyvault_id=$(terraform output keyvault_id)
        storage_account_name=$(terraform output storage_account_name)
        echo ${storage_account_name}
        resource_group=$(terraform output resource_group)
        access_key=$(az storage account keys list --account-name ${storage_account_name} --resource-group ${resource_group} | jq -r .[0].value)
        container=$(terraform output container)
        tf_name="${blueprint_name}.tfstate"

        # Set the security context under the devops app
        export ARM_SUBSCRIPTION_ID=$(az account show | jq -r .id) && echo " - subscription id: ${ARM_SUBSCRIPTION_ID}"
        export ARM_CLIENT_ID=$(terraform output devops_application_id)
        export ARM_CLIENT_SECRET=$(terraform output devops_client_secret)
        export ARM_TENANT_ID=$(az account show | jq -r .tenantId) && echo " - tenant id: ${ARM_TENANT_ID}"
 
        cd "../${blueprint_name}"
        pwd 


        terraform init \
                -reconfigure \
                -backend=true \
                -lock=false \
                -backend-config storage_account_name=${storage_account_name} \
                -backend-config container_name=${container} \
                -backend-config access_key=${access_key} \
                -backend-config key=${tf_name}

        if [ $tf_action == "plan" ]; then
                plan
        fi

        if [ $tf_action == "apply" ]; then
                plan
                apply
                echo "Blueprint successfuly deployed on its orbital layer"
        fi

        if [ ${tf_action} == "destroy" ]; then
                destroy
        fi

        if [ -f ${blueprint_name}.tfplan ]; then
                echo "Deleting file ${blueprint_name}.tfplan"
                rm ${blueprint_name}.tfplan
        fi

        cd "${current_path}"

}

function upload_tfstate {
        echo "Moving launchpad to the cloud"

        storage_account_name=$(terraform output storage_account_name)
        resource_group=$(terraform output resource_group)
        access_key=$(az storage account keys list --account-name ${storage_account_name} --resource-group ${resource_group} | jq -r .[0].value)
        container=$(terraform output container)
        tf_name="${blueprint_name}.tfstate"

        blobFileName=$(terraform output tfstate-blob-name)

        az storage blob upload -f terraform.tfstate \
                -c ${container} \
                -n ${blobFileName} \
                --account-key ${access_key} \
                --account-name ${storage_account_name}

        rm -f terraform.tfstate

}

function get_remote_state_details {
        echo ""
        echo "Getting level0 launchpad coordinates:"
        stg=$(az storage account show --ids ${id})

        export storage_account_name=$(echo ${stg} | jq -r .name) && echo " - storage_account_name: ${storage_account_name}"
        export resource_group=$(echo ${stg} | jq -r .resourceGroup) && echo " - resource_group: ${resource_group}"
        export access_key=$(az storage account keys list --account-name ${storage_account_name} --resource-group ${resource_group} | jq -r .[0].value) && echo " - storage_key: retrieved"
        export container=$(echo ${stg}  | jq -r .tags.container) && echo " - container: ${container}"
        location=$(echo ${stg} | jq -r .location) && echo " - location: ${location}"
        export tf_name="${blueprint_name}.tfstate"
}

function display_instructions {
        echo "You can deploy a landing zone / blueprint from the launchpad by running ./launchpad.sh [blueprint_folder_name|launchpad_folder_name] [plan|apply|destroy]"
        echo ""
        echo "You must set a blueprint_name as in the list:"
        for i in $(ls -d blueprint*/); do echo ${i%%/}; done

        echo ""
        echo "Or you must set a landing zone as in the list:"
        for i in $(ls -d landingzone*/); do echo ${i%%/}; done
        echo ""
}

<#
    .SYNOPSIS
        Get the Launchpad in an Azure subscription.

    .DESCRIPTION
        Finds a Launchpad storage account in the currently selected
        Azure subscription and returns it.

        If the Launchpad storage account does not exist or
        could not be found then null is returned.
#>
function Get-LaunchPad
{
    [CmdletBinding()]
    [OutputType([Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount])]
    param ()

    return Get-AzResource -TagName 'stgtfstate' -TagValue 'level0' -ResourceType 'Microsoft.Storage/storageAccounts' |
        Get-AzStorageAccount 
}

# SAMPLE FILE FOR OPERATIONS BLUEPRINT
# Check documentation and design decisions on Wiki: https://dev.azure.com/azure-terraform/Blueprints/_wiki/ 

# #Azure Site Recovery Configuration
asr_vault_name = "asr"

asr_diags = {
    log = [
                # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
                ["AzureBackupReport", true, true, 30],
                ["AzureSiteRecoveryJobs", true, true, 30],
                ["AzureSiteRecoveryEvents", true, true, 30],
                ["AzureSiteRecoveryReplicatedItems", true, true, 30],
                ["AzureSiteRecoveryReplicationStats", true, true, 30],
                ["AzureSiteRecoveryRecoveryPoints", true, true, 30],
                ["AzureSiteRecoveryReplicationDataUploadRate", true, true, 30],
                ["AzureSiteRecoveryProtectedDiskDataChurn", true, true, 30],
        ]
    metric = [
               #["AllMetrics", 60, True],
    ]
}


#Azure Automation account name
auto_account = "azauto"

auto_diags = {
    log = [
                # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
                ["JobLogs", true, true, 30],
                ["JobStreams", true, true, 30],
                ["DscNodeStatus", true, true, 30],
        ]
    metric = [
                # ["Category name",  "Metric Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
                ["AllMetrics", true, true, 30],
    ]
}
# Blueprint blueprint_operations
blueprint_operations brings the foundation of operations for a subscription. <br/>


## Prerequisites
blueprint_operations requires that blueprint_tranquility is in place. 


## Getting Started
As an example of configuration, use the proto.operations.auto.tfvars provided in the repository. 


## Components

 - Azure Site Recovery
 - Azure Site Recovery customizable diagnostics settings
 - Azure Automation
 - Azure Automation customizable diagnostics settings 


## Notes
By default, the created Azure automation account is not linked to the existing Azure Monitor Log Analytics, this should be enabled separately. 

## Customization 
Refer to the networking_shared_services.auto.tfvars allows you to deploy your first version of the blueprint.

## Outputs 
Returns the ASR object:
```hcl
output "asr_object" {
  value = module.site_recovery
}
```

Returns the Azure automation object:
```hcl
output "auto_object" {
  value = module.automation
}
```hcl 

# Contribute
Pull requests are welcome to evolve the framework and integrate new features!
# <NOT READY FOR RELEASE>
# Blueprint blueprint_operastions
blueprint_networking_shared_services brings the foundation of shared services (hub) network in a hub-spoke topology. <br/>

It's job is to provide with the network configuration for central services, including operations logs and tracing, jumpboxes foundation, etc. <br/>

After running, tranquility exports to the shared TF state a set of output variables thast will be reused in subsequent blueprints.  

## Prerequisites
blueprint_tranquility is required in order to launch blueprint_networking_shared_services.
It will use the data from the shared Terraform state in order to place resources in the right resource groups and operations logs inside the designated repositories.  

## Outputs 
blueprint_networking_shared_services will export data in its shared_state that will be used to leverage the following blueprints (non exhaustive list):
1. networking_shared_egress
2. networking_shared_transit
3. networking_shared_ingress


## Getting Started
As an example of configuration, use the networking_shared_services.auto.tfvars provided in the repository. 
 <br/>
 In order to get started with blueprint_networking_shared_services, simply run: 
```
./launchpad.sh blueprint_networking_shared_services apply
```
## Components

![tranquility diagram](https://raw.githubusercontent.com/aztfmod/blueprints/master/blueprint_tranquility/tranquility.png "tranquility diagram")

## Capabilities

 - Virtual network
    - Virtual network address space
    - DNS Servers 
    - Subnets
        - Subnet address space
        - Network Security Groups 
        - Virtual Network Service Endpoints
        - NSG diagnostics
    - Attach NSG to subnet
    - Virtual network operations logs and auditing
 - (Preview) Network Monitoring 
    - Deploys a (B1ls) VM for network monitoring
    - Configures Network Performance Monitor and Network Watcher extensions. 


## Customization 
Refer to the networking_shared_services.auto.tfvars allows you to deploy your first version of the blueprint.

## Foundations
The output of blueprint_tranquility will be stored in Azure Storage Account and will be read by subsequent modules. <br/> Please do not modify the provided output variables but add additionnal below if you need to extend the model.



# Contribute
Pull requests are welcome to evolve the framework and integrate new features!
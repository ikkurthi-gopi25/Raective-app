# Setup for the infrastructure pipeline
Initially i created 3 folders
1. .guthub/workflows -> This folder contains the pipeline yaml conf files.
   app.yaml -> this yaml file contains the steps for the automatic application deployment
   infra.yaml -> this yml file contains the steps for the automatic infrastructure deployment

2. I have created the Infra folder where all the terraform configarion files will reside
3. application folder ie--react-native-notes-app

-> Initially i have written the infrastructure pipeline creation in the infra.yaml
-> I have used the terraform cloud to store the terraform state file and also for the collaboration
-> in the infra folder i have created the modules folder,inside that i have kept security group module.modules helps us to organize,reuse,and maintain terraform code effeciently
security group module
--------------------
inside this module i have created main.tf,output.tf and variables.tf files

1. backend.tf --> to store the statefile in a remote backend
2. main.tf --> it is the main terraform configaration file,we create data source,ingress and egress security group rules and also the ec2 instance creation
3. output.tf --> it is a terraform conf file that defines the output
4. providers.tf --> it defines and configures the required providers
5. terraform.auto.tfvars --> Terraform automatically loads this file without requiring -var-file during execution
6. variables.tf --> it defines the input variables that make terraform configartions more flexible and reusable


when we made any change to the infra folder automatically the pipeline gets triggered,the steps are going to run which is defined in the infra.yaml file.

1. terraform init: this cmd initializes the terraform project by downloading the req providers,setting up backend storage, and preparing the working directory
2. terraform validate: checks the terraform configartion is syntactically and logically correct
3. terraform plan: creates an execution plan by checking what changes will be applied to the infrastructure
4. terraform apply: it actually creates the infrastructure on the aws
5. terraform destroy: it destroys the created infrastructure

we are delegating on the above steps to the terraform cloud,at the apply stage it will ask for confirmation,when we click on the confirm it will actually create the infra on aws


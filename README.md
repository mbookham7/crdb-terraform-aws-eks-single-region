# CockroachDB  - Terraform Managed Amazon EKS Single-region Database

This repo is the Terraform code to deploy a single CockroachDB Cluster into a EKS cluster into one region.

1. Login in to Amazon Cloud for CLI access by setting the following environment variables.

```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

2. Update the `tfvars` file with you required settings prior to deploying your infrastructure.

```
region_1 = "eu-west-1"
location_1 = "eu-west-1a"
location_2 = "eu-west-1b"
prefix = "mb-crdb-sr"
```

3. To initialize the code you need to run the `terraform init` command. The `terraform init` command initializes a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

```
terraform init
```

4. The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:

- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

```
terraform plan
```

5. The `terraform apply` command executes the actions proposed in a Terraform plan.

```
terraform apply --auto-approve
```

6. When you have deployed your infrastructure you can add the EKS cluster to your local `KUBECONFIG` file. Once you have done this you will be able to communicate with your cluster via `kubectl`

```
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

7. To be able to log on to the UI we need to create a user. To do this we need to deploy a pod with the cockroach binary and connect to our Cockroach cluster and add a user. First we deploy a pod into the correct namespace.

```
kubectl create -f https://raw.githubusercontent.com/cockroachdb/cockroach/master/cloud/kubernetes/multiregion/client-secure.yaml --namespace $(terraform output -raw crdb_namespace_region_1)
```

8. Now we connect to the pod.

```
kubectl exec -it cockroachdb-client-secure -n $(terraform output -raw crdb_namespace_region_1) -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

9. Create a user and grand admin to that user.

```
CREATE USER craig WITH PASSWORD 'cockroach';
GRANT admin TO craig;
```


10. In the AWS Console, navigate to the correct region and then to Elastic Kubernetes Service. Click on the newly created cluster, navigate to `resources` and in the left list click `Service and networking`. Under this section click `Service`. This lists all of the services created in the cluster, click on `cockroachdb-adminui`. In the info pane you will see `Load balancer URLs` listed, add this URL to your browser appending the edn with the port number `8080`


11. The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.

While you will typically not want to destroy long-lived objects in a production environment, Terraform is sometimes used to manage ephemeral infrastructure for development purposes, in which case you can use terraform destroy to conveniently clean up all of those temporary objects once you are finished with your work.

```
terraform destroy
```
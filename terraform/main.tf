# provider "google" {
#     project = "terraformtest-294601" 
#     region  = "us-central1"
# 	zone    = "us-central1-c"
# 	credentials = ("serviceaccount.json")
# }

provider "google" {
	credentials = file("../serviceaccount.json")
	project = "terraformtest-294601" 
	region      = "us-central1"
	version     = "~> 2.5.0"
}

terraform {
    backend "local" {
		path = "./terraform.tfstate"
	}
}
module "network" {
	source = "./modules/network"
	// base network parameters
	network_name     = "kube"
	subnetwork_name  = "kube-subnet"
	region           = "us-central1"
	// subnetwork primary and secondary CIDRS for IP aliasing
	subnetwork_range    = "10.40.0.0/16"
	subnetwork_pods     = "10.41.0.0/16"
	subnetwork_services = "10.42.0.0/16"
}

module "cluster" {
	source                           = "./modules/gke/vpc"
	region                           = "us-central1-a"
	name                             = "gke-example"
	project                          = "terraform-module-cluster"
	network_name                     = "kube"
	nodes_subnetwork_name            = module.network.subnetwork
	kubernetes_version               = "1.16.13-gke.401"
	pods_secondary_ip_range_name     = module.network.gke_pods_1
	services_secondary_ip_range_name = module.network.gke_services_1
}

module "node_pool" {
	source             = "./modules/gke/node-pool"
	name               = "gke-example-node-pool"
	region             = module.cluster.region
	gke_cluster_name   = module.cluster.name
	machine_type       = "n1-standard-4"
	min_node_count     = "1"
	max_node_count     = "1"
	kubernetes_version = module.cluster.kubernetes_version
}
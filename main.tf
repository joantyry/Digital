# Specify the Terraform provider for Google Cloud
provider "google" {
  project = "digital-12345" # Replace with your GCP Project ID
  region  = "us-central1"         # Replace with your desired region
  zone    = "us-central1-a"       # Replace with your desired zone
}
#(6) Declare the static IP resource
resource "google_compute_address" "static_ip" {
  name   = "my-static-ip"
  region = "us-central1"
}


#(7) Define ssh rules

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ips
  target_tags = ["allow-ssh"]

  description = "Allow SSH access from specific IP ranges"
}

variable "allowed_ips" {
  description = "List of allowed IP ranges for SSH access"
  type        = list(string)
  default     = ["<your-public-ip>"] # Replace with your desired IP address/range
}


# Define the Google Cloud VM instance
resource "google_compute_instance" "almalinux_vm" {
  name         = "almalinux-9-vm"
  machine_type = "e2-medium"       # Adjust as needed

  # Specify the boot disk with AlmaLinux 9
  boot_disk {
    initialize_params {
      image = "almalinux-cloud/almalinux-9" # AlmaLinux 9 image
      size  = 30                     # Root volume size in GB
    }
  }

  # Define the additional data disk
  attached_disk {
    source      = google_compute_disk.docker_disk.id
    device_name = "docker-disk"
  }

  # Configure the network interface
  network_interface {
    network = "default"

    access_config {
    
      #(6) This configures a public IP for the VM
      nat_ip = google_compute_address.static_ip.address

    }
  }

 #(3-5) cloud-init file contains code to format docker disk with xfs and create users
    metadata_startup_script = file("/home/kali/Terraform/Digital-terraform/cloud-init.sh") # use absolute path to the file
 
  }
#}

# Define the additional data disk
resource "google_compute_disk" "docker_disk" {
      name  = "docker-disk"
      size  = 15                 # Data volume size in GB
      type  = "pd-balanced"      # Use a balanced persistent disk
      zone  = "us-central1-a"    # Match the zone of the VM
 }

#(6) Output the public IP address of the VM
output "instance_ip" {
  value = google_compute_instance.almalinux_vm.network_interface[0].access_config[0].nat_ip
}



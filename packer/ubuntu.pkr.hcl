packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "subnet_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-2"
}

source "amazon-ebs" "amd" {
  region                      = var.region
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }
  instance_type = "t3a.medium"
  ssh_username  = "ubuntu"
  ami_name      = "amd64-{{timestamp}}"
  tags = {
    timestamp      = "{{timestamp}}"
    consul_enabled = true
    nomad_enabled = true
  }
}

source "amazon-ebs" "arm" {
  region                      = var.region
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }
  instance_type = "t4g.medium"
  ssh_username  = "ubuntu"
  ami_name      = "arm64-{{timestamp}}"
  tags = {
    timestamp      = "{{timestamp}}"
    consul_enabled = true
    nomad_enabled = true
  }
}

build {
  sources = [
    "source.amazon-ebs.amd",
    "source.amazon-ebs.arm"
  ]

  hcp_packer_registry {
    bucket_name = "ubuntu-lunar-hashi"
    description = "Ubuntu Lunar Lobster with Nomad and Consul installed"

    bucket_labels = {
      "os"             = "Ubuntu",
      "ubuntu-version" = "23.04",
    }

    build_labels = {
      "timestamp"      = timestamp()
      "consul_enabled" = true
      "nomad_enabled" = true
    }
  }

  provisioner "shell" {
    inline = [
      "sudo add-apt-repository universe",
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee -a /etc/apt/sources.list.d/hashicorp.list",
      //"echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) test\" | sudo tee -a /etc/apt/sources.list.d/hashicorp.list",
      "sudo cat /etc/apt/sources.list",
      "sudo apt-get install -y dialog apt-utils unzip",
      "curl --silent --remote-name https://releases.hashicorp.com/nomad/1.7.6/nomad_1.7.6_linux_amd64.zip",
      "unzip nomad_1.7.6_linux_amd64.zip",
      "sudo chown root:root nomad",
      "sudo mv nomad /usr/local/bin/",
      "nomad -autocomplete-install"
    ]
  }
}
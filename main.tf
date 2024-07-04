provider "local" {
  version = "~> 2.0"
}
provider "null" {
  version = "~> 3.0"
}
provider "tls" {
  version = "~> 3.0"
}
provider "random" {
  version = "~> 3.0"
}

variable "server_ip" {
  description = "The IP address of the Ubuntu server"
  type        = string
}

variable "priv_key" {
  description = "Path to the private key"
  type        = string
}

resource "null_resource" "ensure_directories" {
  provisioner "remote-exec" {
    inline = [
      "if [ ! -d /etc/prometheus ]; then sudo mkdir -p /etc/prometheus; fi",
      "if [ ! -d /var/lib/prometheus ]; then sudo mkdir -p /var/lib/prometheus; fi",
      "sudo chown prometheus:prometheus /etc/prometheus",
      "sudo chown prometheus:prometheus /var/lib/prometheus"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file(var.priv_key) 
    host        = var.server_ip
  }

  # Use a dynamic value to trigger every apply
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "install_prometheus" {
  # Use a dynamic value to trigger every apply
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    null_resource.ensure_directories
  ]

  provisioner "remote-exec" {
      inline = [
        "git clone https://github.com/sanfx/server-installs.git",
        "cd server-installs",
        "chmod +x install_prometheus.sh",
        "./install_prometheus.sh"
      ]
    }

    connection {
      type        = "ssh"
      user        = "ansible"
      private_key = file(var.priv_key) 
      host        = var.server_ip
    }

}

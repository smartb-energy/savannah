resource "triton_machine" "development-postgres" {
  count = 3
  image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
  name    = "dev-postgres-${count.index}"
  package = "g4-highcpu-2G"
  connection {
    user = "root"
    host = "${self.primaryip}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "chef" {
    environment = "development"
    run_list = ["servers::default"]
    node_name = "${self.name}"
    server_url = "https://api.chef.io/organizations/smartb"
    user_name = "${var.chef_username}"
    user_key = "${file("${var.chef_user_key}")}"
    recreate_client=true
    version = "12.17.44"
  }

  provisioner "file" {
    destination = "supervisor.service"
    content = <<EOF
[Unit]
Description=The Habitat Supervisor

[Service]
ExecStart=/bin/hab sup run --peer ${triton_machine.development-postgres.0.primaryip}

[Install]
WantedBy=default.target
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "useradd --system hab",
      "curl -sL https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | bash",
      "hab pkg install core/hab-sup",
      "mv supervisor.service /etc/systemd/system/supervisor.service",
      "systemctl daemon-reload",
      "systemctl start supervisor",
      "systemctl enable supervisor",
      "hab svc load starkandwayne/postgresql --group development --topology leader --channel unstable"
    ]
  }
}

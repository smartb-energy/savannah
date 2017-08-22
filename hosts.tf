resource "triton_machine" "dev-postgres" {
  count = 3
  image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
  name    = "dev-postgres-${count.index}"
  package = "g4-highcpu-2G"
  connection {
    user = "root"
    host = "${self.primaryip}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    destination = "supervisor.service"
    content = <<EOF
[Unit]
Description=The Habitat Supervisor

[Service]
ExecStart=/bin/hab sup run --peer ${triton_machine.dev-postgres.0.primaryip}

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
      "hab svc load core/postgresql --group dev --topology leader"
    ]
  }
}

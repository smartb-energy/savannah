resource "triton_machine" "dev-permanent-peer" {
    image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
    name    = "dev-permanent-peer"
    package = "g4-highcpu-256M"
    connection {
        user = "root"
        host = "${self.primaryip}"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    nic = {
      network = "ccccb251-1b24-457a-8b46-459e2199882e"
    }

    provisioner "file" {
      source      = "supervisor.service"
      destination = "/etc/systemd/system/supervisor.service"
    }

    provisioner "remote-exec" {
        inline = [
            "hostname ${self.name}",
            "useradd --system hab",
            "curl -sL https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash",
            "systemctl daemon-reload && systemctl start supervisor"
        ]
    }
}

resource "triton_machine" "dev-postgres" {
    count = 2
    depends_on = ["triton_machine.dev-permanent-peer"]
    image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
    name    = "dev-postgres-${count.index}"
    package = "g4-highcpu-512M"
    connection {
        user = "root"
        host = "${self.primaryip}"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    nic = {
      network = "ccccb251-1b24-457a-8b46-459e2199882e"
    }

    provisioner "file" {
      source      = "supervisor.service"
      destination = "/etc/systemd/system/supervisor.service"
    }

    provisioner "remote-exec" {
        inline = [
            "hostname ${self.name}",
            "useradd --system hab",
            "curl -sL https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash",
            "systemctl daemon-reload && systemctl start supervisor",
            "HAB_NONINTERACTIVE=true hab pkg install core/postgresql --channel unstable",
            "mkdir --parents /hab/svc/postgresql94 && chown --recursive hab /hab/svc/postgresql94"
        ]
    }

    provisioner "file" {
      source      = "user.toml"
      destination = "/hab/svc/postgresql94/user.toml"
    }

    provisioner "remote-exec" {
        inline = [
            "hab svc start smartb/postgresql94 --group dev --topology standalone --peer ${triton_machine.dev-permanent-peer.primaryip}"
        ]
    }
}

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
            "curl -sL https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash -s -- -v 0.25.1",
            "systemctl daemon-reload && systemctl start supervisor"
        ]
    }
}

resource "triton_machine" "dev-postgres" {
    count = 2
    depends_on = ["triton_machine.dev-permanent-peer"]
    image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
    name    = "dev-postgres-${count.index}"
    package = "g4-highcpu-4G"
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
            "curl -sL https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash -s -- -v 0.25.1",
            "systemctl daemon-reload && systemctl start supervisor",
            "hab pkg install core/postgresql",
            "hab svc start core/postgresql --group dev --topology leader --peer ${triton_machine.dev-postgres-permanent-peer.primaryip}"
        ]
    }
}

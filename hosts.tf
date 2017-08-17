provider "triton" {
    account      = "smartb"
    key_material = "${file("~/.ssh/id_rsa")}"
    key_id       = "93:50:bb:2b:dd:bf:68:6a:0f:b7:cf:f8:15:1d:e9:b9"
    url = "https://eu-ams-1.api.joyentcloud.com"
}

resource "triton_machine" "dev-postgres-permanent-peer" {
    image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
    name    = "dev-postgres-permanent-peer"
    package = "g4-highcpu-1G"
    connection {
        user = "root"
        host = "${self.primaryip}"
        private_key = "${file("~/.ssh/id_rsa")}"
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
            "hab svc start core/postgresql --group dev --topology leader --permanent-peer"
        ]
    }
}

resource "triton_machine" "dev-postgres" {
    count = 2
    depends_on = ["triton_machine.dev-postgres-permanent-peer"]
    image   = "7b5981c4-1889-11e7-b4c5-3f3bdfc9b88b"
    name    = "dev-postgres-${count.index}"
    package = "g4-highcpu-1G"
    connection {
        user = "root"
        host = "${self.primaryip}"
        private_key = "${file("~/.ssh/id_rsa")}"
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

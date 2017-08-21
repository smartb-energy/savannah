provider "triton" {
    account      = "smartb"
    key_material = "${file("~/.ssh/id_rsa")}"
    key_id       = "93:50:bb:2b:dd:bf:68:6a:0f:b7:cf:f8:15:1d:e9:b9"
    url = "https://eu-ams-1.api.joyentcloud.com"
}

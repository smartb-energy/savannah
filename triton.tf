# We use Joyent's Triton cloud for internal testing. Community collaborators
# can set up a free account via http://lpage.joyent.com/Triton-Free-Trial.html
# To get the correct TF_VAR_ environment variables for these Terraform configs,
# first install the Triton cli tools for your account like `npm install -g triton`
#
# Your `.bash_profile` entry might look like:
#
# eval "$(triton env)"
# export TF_VAR_triton_key_id=$SDC_KEY_ID
# export TF_VAR_triton_account=$SDC_ACCOUNT
# export TF_VAR_triton_url=$SDC_URL

provider "triton" {
    account      = "${var.triton_account}"
    key_material = "${file("~/.ssh/id_rsa")}"
    key_id       = "${var.triton_key_id}"
    url = "${var.triton_url}"
}

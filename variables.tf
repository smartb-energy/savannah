# Declaring an empty variable will result in a prompt at the Terraform CLI.
# Variables can also be imported from the *nix environment if they have the
# `TF_VAR_` prefix. For example, `export TF_VAR_instance_key_name=$USER`

variable "triton_key_id" {}
variable "triton_account" {}
variable "triton_url" {}
variable "chef_user_key" {}
variable "chef_username" {}

pkg_name=postgresql94
pkg_version=9.4.11
pkg_origin=smartb
pkg_maintainer="smartB Engineering <dev@smartb.eu>"
pkg_description="PostgreSQL is a powerful, open source object-relational database system."
pkg_upstream_url="https://www.postgresql.org/"
pkg_license=('PostgreSQL')
pkg_source=null
pkg_shasum=null
pkg_deps=(core/postgresql94)
pkg_exports=(
  [port]=port
  [superuser_name]=superuser.name
  [superuser_password]=superuser.password
)
pkg_exposes=(port)
pkg_svc_user=root
pkg_svc_group=$pkg_svc_user

do_download() {
    return 0
}

do_verify() {
    return 0
}

do_unpack() {
    return 0
}

do_build() {
    return 0
}

do_install() {
    return 0
}

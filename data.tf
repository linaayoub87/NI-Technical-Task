data "template_file" "this" {
  template = file("${path.cwd}/file/userdata")
}
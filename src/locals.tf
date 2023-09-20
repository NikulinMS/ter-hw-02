locals {
  web = "${ var.name }-${ var.env }-${ var.project }-${ var.role[0] }"
  db = "${ var.name }-${ var.env }-${ var.project }-${ var.role[1] }"
}
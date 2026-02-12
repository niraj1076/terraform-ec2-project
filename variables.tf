variable "region" {
  default = "ap-south-1"
}

variable "instance-type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Exixstin aws key"
  type = string
}
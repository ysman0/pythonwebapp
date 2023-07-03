variable "ami" {
  description = "Amazon image for EC2 Instance"
  type        = string
  default     = "ami-0eb260c4d5475b901"
}

variable "ec2_instance_type" {
  description = "ec2 Instance type"
  type        = string
  default     = "t2.micro"
}
variable "availability_zone_EUWEST" {
  description = "euwest av zone"
  type        = string
  default     = "eu-west-2a"
}

variable "ec2_key" {
  description = "ec2 key"
  type        = string
  default     = "project1"
}

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "ys"
}

variable "subnets" {
  description = "network subnets"
  type        = any
}

variable "tag" {
  description = "project tag"
  type        = string
}

variable "VPC_network_block" {
  description = "Main Network"
}

variable "yusuf_ip" {
  description = "my ip"

}

variable "webserver_privateip" {
  description = "webserver ip"
  type        = string

}

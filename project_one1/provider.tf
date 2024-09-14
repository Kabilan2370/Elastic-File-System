
provider "aws" {
    region = var.us_east
}

provider "aws" {
    alias = "ap_south"
    region = var.ap_south
}

provider "aws" {
    alias = "ap_southeast"
    region = var.ap_southeast
}
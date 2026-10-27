provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

module "sg" {
    source = "../22-modules-local-A/network" 
    providers = {
        aws.prod = aws.mumbai
    
}
}
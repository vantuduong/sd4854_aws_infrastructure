module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-instance"

  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = "t2.large"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.security_group.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  user_data = <<EOF
#!/bin/bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo dnf install java-11-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo yum update -y
sudo yum install docker -y
sudo systemctl enable docker.service --now
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker jenkins
sudo service docker start
sudo yum install git -y
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
sudo systemctl restart jenkins
sudo su & sudo curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.47.0
EOF
}
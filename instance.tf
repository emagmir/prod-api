resource "aws_instance" "docudb_test" {
  ami           = "ami-0a3c3a20c09d6f377" # us-west-2
  instance_type = "t3.micro"

  tags = {
    Name = "Minimal-T3-Micro-Instance"
  }

  key_name               = aws_key_pair.tf_test_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_from_home.id]

  user_data_base64 = "${base64encode(local.instance-userdata)}"
}

locals {
  instance-userdata = <<EOF
#!/bin/bash
touch /etc/yum.repos.d/mongodb-org-7.0.repo
echo "[mongodb-org-7.0] \
name=MongoDB Repository \
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/ \
gpgcheck=1 \
enabled=1 \
gpgkey=https://pgp.mongodb.com/server-7.0.asc" > /etc/yum.repos.d/mongodb-org-7.0.repo
sudo yum update -y
dnf install -qy mongodb-mongosh-shared-openssl3
sudo wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
EOF
}

resource "aws_key_pair" "tf_test_key" {
  key_name   = "tf_test_key" # Replace with your key pair name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCc4x67aefsLE/JYdF8BURF+vVj5jgP2v8sjStVmo2EzjKYmjgPqvTHMCQ9tF2U/7Govbm2sEEK7jjEXwSc+ZEgvXxgj8+lOEzLYWWK+zcRP/AiHuSXSgmUHQgMj5y9OtNzBnRN75BYIJIfsuxYswe3tlBj3xZmiYn5ZveX0e4/pijULmU24fiMuZtDYr9fQ2xcgXCde/0MmRa34DQAClcHywXJU4Ea8y1ONeotE47yviUtMGyzvXTeXN3UuaKu3HnWWWclz0o0Hh1n0MYgxOAw1u1pduuZi21Qlo/dxtg3wLHDFa2hMM0aZ68DbMYtLJCfUSI5lp0nZIJsm217qd4hK67cH35c+UprcohapIqc64I/Gg5diM3hNaI4q1lJ/2FdZQ7kRkPjinHUegyw74SreQwE9R1eK2FmpLcDOhhirBNV+P2zPRzlBAnOtBlyJLsp6GXIlhrDR+gfEOvpONrfumpXndzdBrzZJrUr9eHK8Ek1s8o3T3HttRe78mhx76M= xmagu@DESKTOP-TR0BK6Q"
}
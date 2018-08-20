# generate random username and password
resource "random_string" "vm-username" {
  length = 10
  special = false
}

resource "random_string" "random-name-suffix" {
  length = 10
  special = false
  upper = false
  number = false
  lower = true
}


resource "random_string" "vm-password" {
  length = 16
  special = true
}
output "devname" {
  # value = aws_vpc.petclinic.id
  value = aws_vpc.petclinic.cidr_block
}

target "default" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["ghcr.io/jakelogemann/images:default"]
  # args = {
  #   name = "foo"
  # }
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/386"
  ]
}

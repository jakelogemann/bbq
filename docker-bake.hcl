target "default" {
  context = "."
  dockerfile = "Dockerfile"
  # args = {
  #   name = "foo"
  # }
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/386"
  ]
}

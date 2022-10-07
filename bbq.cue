package bbq

registry:       "ghcr.io"
project_name:   "bbq"
repository:     "github.com/\(owner)/\(project_name)"
repository_url: "https://\(repository)"
owner:          "jakelogemann"
#semver:        string & =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
#platform:      *"linux/arm64" | *"linux/amd64"

#BakeTarget: {
	context: string
	tags: [...string]
	platforms: [...#platform]
	labels: [string]: string
	...
}

#BakeGroup: {
	targets: [string]
	...
}

#BakeConfig: {
	group: [string]:  #BakeGroup
	target: [string]: #BakeTarget
}

files: {

	"docker-bake.json": #BakeConfig & {
		group: {
			"default": #BakeGroup & {
				"targets": [
					"default",
				]
			}
		}

		"target": {
			"alpine": {
				"context":           "."
				"dockerfile":        "Dockerfile"
				"dockerfile-inline": "FROM alpine\n"
				"labels": {
					"org.containers.image.source": repository_url
				}
				"tags": [
					"\(registry)/\(owner)/alpine:latest",
				]
				"platforms": [
					"linux/amd64",
					"linux/arm64",
				]
			}
			"default": {
				"context":           "."
				"dockerfile":        "Dockerfile"
				"dockerfile-inline": "FROM scratch\n"
				"tags": [
					"\(registry)/\(owner)/default:latest",
				]
				"labels": {
					"org.containers.image.source": repository_url
				}
				"platforms": [
					"linux/amd64",
				]
			}
		}
	}
}

package bbq

registry:       "ghcr.io"
project_name:   "bbq"
repository:     "github.com/\(owner)/\(project_name)"
repository_url: "https://\(repository)"
owner:          "jakelogemann"

files: {
	"docker-bake.json": #BakeConfig & {
		group: {
			default: {
				targets: [
					"default",
				]
			}
		}

		target: {
			alpine: {
				context:             "."
				dockerfile:          "Dockerfile"
				"dockerfile-inline": "FROM alpine\n"
				labels: {
					"org.containers.image.source": repository_url
				}
				tags: [
					"\(registry)/\(owner)/alpine:latest",
				]
				platforms: [
					"linux/amd64",
					"linux/arm64",
				]
			}
			default: {
				context:             "."
				dockerfile:          "Dockerfile"
				"dockerfile-inline": "FROM scratch\n"
				tags: [
					"\(registry)/\(owner)/default:latest",
				]
				labels: {
					"org.containers.image.source": repository_url
				}
				platforms: [
					"linux/amd64",
				]
			}
		}
	}
}

#semver:   string & =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
#label:    string & =~"^[a-z0-9]+(?:[._-][a-z0-9]+)*$"
#target:   string & =~"^[a-z0-9]+$"
#platform: string & =~"^(linux|darwin|windows)/(arm64|amd64|i386|arm)$"

#BakeTarget: {
	context: *"." | string & !=""
	tags: [...string]
	platforms: [...#platform]
	labels: [#label]: string
	"dockerfile-inline"?: string
	dockerfile?:          string
	...
}

#BakeGroup: {
	targets: [#target]
}

#BakeConfig: {
	group: [string]:  #BakeGroup
	target: [string]: #BakeTarget
}

package bbq

import (
	"polis.dev/v0"
	"path"
)

registry:       "ghcr.io"
project_name:   "bbq"
repository:     "github.com/\(owner)/\(project_name)"
repository_url: "https://\(repository)"
owner:          "jakelogemann"
imageNames: ["default", "ubuntu"]

docker_bake_config: v0.#BakeConfig & {
	group: {
		// all: targets: imageNames
		for _, target in imageNames {
			"\(target)": v0.#BakeGroup & {targets: [target]}
		}
	}
	target: {
		for _, target in imageNames {
			"\(target)": v0.#BakeTarget & {
				_imageName: path.Join([registry, repository, project_name, target], "unix")
				context:    "./images/\(target)"
				dockerfile: "Dockerfile"
				labels: "org.containers.image.source": repository_url
				labels: "org.containers.image.title":  target
				tags: [ "\(_imageName):latest"]
				platforms: ["linux/amd64"]
			}
		}
	}
}

github_workflows: {
	for _, target in imageNames {
		"\(target)": {
			v0.#Workflow & {
				name: "\(target)"
				on: {
					pull_request: types: [
						"opened",
						"synchronize",
					]
					push: branches: [
						"main",
					]
				}

				jobs: build: {
					"runs-on": "ubuntu-latest"
					steps: [
						{
							uses: "actions/checkout@v3.1.0"
						},
						{
							uses: "cue-lang/setup-cue@main"
						},
						{
							run: "cue version"
						},
						{
							run: "cue cmd generate"
						},
						{
							run: "cue cmd build"
						},
						{
							name:                "error if uncommitted changes"
							run:                 "test -z \"$(git status --porcelain)\" || (git status; git diff; false)"
							"continue-on-error": true
						},
					]
				}
			}
		}
	}
}

package bbq

import (
	"json.schemastore.org/github"
	"path"
)

registry:       "ghcr.io"
project_name:   "bbq"
repository:     "github.com/\(owner)/\(project_name)"
repository_url: "https://\(repository)"
owner:          "jakelogemann"
imageNames: ["default", "ubuntu"]

docker_bake_config: #BakeConfig & {
	group: {
		// all: targets: imageNames
		for _, target in imageNames {
			"\(target)": #BakeGroup & {targets: [target]}
		}
	}
	target: {
		for _, target in imageNames {
			"\(target)": #BakeTarget & {
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
			github.#Workflow & {
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

#SemVer:         string & =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
#Label:          string & =~"^[a-z0-9]+(?:[._-][a-z0-9]+)*$"
#BakeTargetName: string & =~"^[a-z0-9]+$"
#Platform:       string & =~"^(linux|darwin|windows)/(arm64|amd64|i386|arm)$"
#BakeGroup: targets: [#BakeTargetName]
#BakeTarget: {
	context: *"." | string & !=""
	tags: [...string]
	platforms: [...#Platform]
	labels: [#Label]: string
	"dockerfile-inline"?: string
	dockerfile?:          string
	...
}

#BakeConfig: {
	group: [string]:           #BakeGroup
	target: [#BakeTargetName]: #BakeTarget
}

#WorkflowFile: {filename: string, workflow: github.#Workflow}
#WorkflowFiles: [...#WorkflowFile]

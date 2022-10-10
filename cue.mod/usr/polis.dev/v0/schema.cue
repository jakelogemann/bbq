package v0

import (
	"json.schemastore.org/github"
)

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

#Workflow: github.#Workflow
#WorkflowFile: {filename: string, workflow: github.#Workflow}
#WorkflowFiles: [...#WorkflowFile]

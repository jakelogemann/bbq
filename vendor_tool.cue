package bbq

import (
	"path"
	ls "list"
	"strings"
	"tool/cli"
	"tool/http"
	"tool/exec"
	"tool/file"
)

#repoRoot: exec.Run & {
	cmd:    "git rev-parse --show-toplevel"
	stdout: string
}

// vendor "vendors" 'cue import'-ed versions of the GitHub
// action and workflow schemas into cue.mod/pkg
//
// Under the proposal for CUE packagemanagement, this command is
// redundant.
command: vendor: {
	_goos: *"unix" | string @tag(os,var=os)

	repoRoot: #repoRoot

	getActionJSONSchema: http.Get & {
		// Tip link for humans:
		// https://github.com/SchemaStore/schemastore/blob/master/src/schemas/json/github-action.json
		url: "https://raw.githubusercontent.com/SchemaStore/schemastore/6f19577c833450268973126ee095d42b8f515515/src/schemas/json/github-action.json"
	}

	importActionJSONSchema: exec.Run & {
		stdin:  getActionJSONSchema.response.body
		cmd:    "cue import -f -p github -l #Action: jsonschema: - -o -"
		stdout: string
	}

	vendorGitHubActionSchema: file.Create & {
		_path:    path.FromSlash("cue.mod/pkg/json.schemastore.org/github/github-action.cue", "unix")
		filename: path.Join([strings.TrimSpace(repoRoot.stdout), _path], _goos)
		contents: importActionJSONSchema.stdout
	}

	getWorkflowJSONSchema: http.Get & {
		// Tip link for humans:
		// https://github.com/SchemaStore/schemastore/blob/master/src/schemas/json/github-workflow.json
		url: "https://raw.githubusercontent.com/SchemaStore/schemastore/6fe4707b9d1c5d45cfc8d5b6d56968e65d2bdc38/src/schemas/json/github-workflow.json"
	}

	importWorkflowJSONSchema: exec.Run & {
		stdin:  getWorkflowJSONSchema.response.body
		cmd:    "cue import -f -p github -l #Workflow: jsonschema: - -o -"
		stdout: string
	}

	vendorGitHubWorkflowSchema: file.Create & {
		_path:    path.FromSlash("cue.mod/pkg/json.schemastore.org/github/github-workflow.cue", "unix")
		filename: path.Join([strings.TrimSpace(repoRoot.stdout), _path], _goos)
		contents: importWorkflowJSONSchema.stdout
	}
}

command: validate: exec.Run & {
	cmd: "docker buildx bake --file=docker-bake.json --print"
}

command: build: exec.Run & {
	cmd: "docker buildx bake --file=docker-bake.json"
}

command: list: {
	_commandNames: ls.SortStrings([ for k, _ in command { "\(k)" } ])
	out: cli.Print & {
		text: strings.Join(_commandNames, "\n")
	}
}

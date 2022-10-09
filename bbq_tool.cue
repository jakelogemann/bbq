package bbq

import (
	"encoding/json"
	"encoding/yaml"
	"json.schemastore.org/github"
	"path"
	"strings"
	"tool/http"
	"tool/exec"
	"tool/file"
)

#repoRoot: exec.Run & {
	cmd:    "git rev-parse --show-toplevel"
	stdout: string
}

_preamble: """
	# DO NOT EDIT!!!! Generated (and validated!) by a `cue cmd`
	# ---------------------------------------------------------
	"""

//  command(s) that can be run using `cue cmd <name>`.
command: {
	_goos: *"unix" | string @tag(os,var=os)

	prebake: file.Create & {
		filename: "docker-bake.json"
		contents: json.Marshal(#BakeConfig & docker_bake_config)
	}

	validate: exec.Run & {
		$dep: prebake.$done
		cmd:  "docker buildx bake --file=docker-bake.json --print"
	}

	build: exec.Run & {
		$dep: prebake.$done
		cmd:  "docker buildx bake --file=docker-bake.json"
	}

	// genworkflows exports workflow configurations to .yml files.
	//
	// When the as-yet-unpublished embeding example is implemented,
	// this command will become superfluous and could be replaced
	// by a cue export call.
	generate: {
		repoRoot:      #repoRoot
		for _, target in imageNames {
			"\(target).yml": file.Create & {
				filename:  "\(path.Join([".github", "workflows", target], _goos)).yml"
				contents:  "\(_preamble)\n\(yaml.Marshal(github.#Workflow & github_workflows[target]))"
			}
		}

		done: exec.Run & {
			$dep: [ prebake.$done, for _, n in imageNames {"\(n)"}]
			cmd: "echo done"
		}
	}

	// vendorgithubschema "vendors" 'cue import'-ed versions of the GitHub
	// action and workflow schemas into cue.mod/pkg
	//
	// Under the proposal for CUE packagemanagement, this command is
	// redundant.
	vendorgithubschema: {

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
}

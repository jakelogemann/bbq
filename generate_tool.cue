package bbq

import (
	"encoding/json"
	"encoding/yaml"
	"polis.dev/v0"
	"path"
	"tool/cli"
	"strings"
	"tool/exec"
	"tool/file"
)

command: generate: {
	_goos: *"unix" | string @tag(os,var=os)

	bakeConfig: {
		fileCreated: file.Create & {
			filename: "docker-bake.json"
			contents: json.Marshal(v0.#BakeConfig & docker_bake_config)
		}
		done: cli.Print & {
			$dep: fileCreated.$done
			text: "done"
		}
	}

	for i, target in imageNames {
		"\(target)": {
			f: file.Create & {
				_preamble: strings.TrimSpace("""
					# DO NOT EDIT!!!! Generated (and validated!) by a `cue cmd`
					# ---------------------------------------------------------
					""")
				filename: "\(path.Join([".github", "workflows", target], _goos)).yml"
				contents: "\(_preamble)\n\(yaml.Marshal(v0.#Workflow & github_workflows[target]))"
			}
			reply: exec.Run & {
				$dep: f.$done
				cmd:  "echo \(target) done"
			}
		}
	}

	done: {
		$dep: [ bakeConfig.$done, for _, n in imageNames { "\(n)" } ]
		exec.Run & {
			cmd: "echo all done"
		}
	}
}

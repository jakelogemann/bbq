package bbq

import (
	"json.schemastore.org/github"
)

#WorkflowFile: {filename: string, workflow: github.#Workflow}
#WorkflowFiles: [...#WorkflowFile]

workflows: #WorkflowFiles & [
		{
		filename: "main.yml"
		workflow: github.#Workflow & {
			name: "main"
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
						name: "Checkout"
						uses: "actions/checkout@v2"
					},
					{
						name: "setup cue"
						uses: "cue-lang/setup-cue@main"
						with: version: "0.4.3"
					},
					{
						run: "cue version"
					},
					{
						run:  "cue cmd generate"
					},
					{
						run:  "cue cmd build"
					},
					{
						name: "error if uncommitted changes"
						run:  "test -z \"$(git status --porcelain)\" || (git status; git diff; false)"
						"continue-on-error": true
					},
				]
			}
		}
	},
]

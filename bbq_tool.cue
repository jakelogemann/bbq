package bbq

import (
	"tool/cli"
	"tool/exec"
	"encoding/json"
	"tool/file"
)

// A command named "generate"
command: {
	prebake: file.Create & {
		filename: "docker-bake.json"
		contents: json.Marshal(files["docker-bake.json"])
	}

	generate: cli.Print & {
		$dep: prebake.$done
		text: "Done"
	}

	validate: exec.Run & {
		$dep: prebake.$done
		cmd:  "docker buildx bake --file=docker-bake.json --print"
	}

	build: exec.Run & {
		$dep: prebake.$done
		cmd:  "docker buildx bake --file=docker-bake.json"
	}
}

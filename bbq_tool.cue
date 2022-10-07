package bbq

import (
	"tool/cli"
	"encoding/json"
	"tool/file"
)

// A command named "generate"
command: generate: {
	docker_baker: file.Create & {
		filename: "docker-bake.json"
		contents: json.Marshal(files["docker-bake.json"])
	}

	// also starts after echo, and concurrently with append
	print: cli.Print & {
		$dep: docker_baker.$done
		text: "Done"
	}
}

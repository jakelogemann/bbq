.PHONY: docker-bake.json
docker-bake.json:
	cue eval --out=json --outfile=docker-bake.json -e "docker-bake.json"

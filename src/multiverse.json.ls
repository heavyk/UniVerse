facilmente:
	name: "fácilmente!!"
	version: "0.1.0"
	bundle:
		node: "0.11.13"
		mongo: "2.4.3" # upgrade to 2.6.1
		arango: "2.0"
	contents:
		"third_party/node":
			upstream: "github://joyent/node"
			revision: "v0.11.13"
		"node_modules/weak":
			upstream: "github://duralog/node-weak"
			revision: "master"
		"node_modules/Laboratory":
			upstream: "github://heavyk/Laboratory"
			revision: "master"
		"third_party/ArangoDB":
			upstream: "github://triAGENS/ArangoDB"
			revision: "868dfd206b532ce7b90fcc84446720790b9f1ddd"
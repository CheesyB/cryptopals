package = "cryptopals"
version = "dev-1"
source = {
	url = "src",
}
description = {
	homepage = "*** please enter a project homepage ***",
	license = "*** please specify a license ***",
}
build = {
	type = "builtin",
	modules = {
		["cryptopals"] = "src/main.lua",
	},
}

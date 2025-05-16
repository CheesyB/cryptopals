package = "cryptopals"
version = "dev-1"
source = {
	url = "src",
}
description = {
	homepage = "*** please enter a project homepage ***",
	license = "*** please specify a license ***",
}
dependencies = {
   "lua >= 5.1, < 5.5",
   "inspect >= 3.1",
   "luaunit >= 3.4"
}
build = {
	type = "builtin",
	modules = {
		["cryptopals"] = "src/main.lua",
	},
}

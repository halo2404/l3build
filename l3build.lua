--[[

File l3build.lua Copyright (C) 2014-2017 The LaTeX3 Project

It may be distributed and/or modified under the conditions of the
LaTeX Project Public License (LPPL), either version 1.3c of this
license or (at your option) any later version.  The latest version
of this license is in the file

   http://www.latex-project.org/lppl.txt

This file is part of the "l3build bundle" (The Work in LPPL)
and all files in that bundle must be distributed together.

-----------------------------------------------------------------------

The development version of the bundle can be found at

   https://github.com/latex3/l3build

for those people who are interested.

--]]

-- Version information
release_date = "2018-03-06"

-- File operations are aided by the LuaFileSystem module
local lfs = require("lfs")

-- Local access to functions

local assert           = assert
local ipairs           = ipairs
local lookup           = kpse.lookup
local next             = next
local print            = print
local select           = select
local tonumber         = tonumber
local exit             = os.exit

-- l3build setup and functions

kpse.set_program_name("kpsewhich")
build_kpse_path = string.match(lookup("l3build.lua"),"(.*[/])")
local function build_require(s)
  require(lookup("l3build-"..s..".lua", { path = build_kpse_path } ) )
end

build_require("variables")
build_require("arguments")
build_require("file-functions")
build_require("typesetting")
build_require("aux")
build_require("clean")
build_require("check")
build_require("ctan")
build_require("install")
build_require("unpack")
build_require("manifest")
build_require("manifest-setup")
build_require("tagging")
build_require("help")
build_require("stdmain")

-- Allow main function to be disabled 'higher up'
main = main or stdmain

--
-- Deal with multiple configs for tests
--
 
-- When we have specific files to deal with, only use explicit configs
-- (or just the std one)
if options["names"] then
  checkconfigs = options["config"] or {stdconfig}
else 
  checkconfigs = options["config"] or checkconfigs
end

if options["target"] == "check" then
  if #checkconfigs > 1 then
    local errorlevel = 0
    local opts = options
    for i = 1, #checkconfigs do
      opts["config"] = {checkconfigs[i]}
      errorlevel = call({"."}, "check", opts)
      if errorlevel ~= 0 then exit(1) end
    end
    -- Avoid running the 'main' set of tests twice
    exit(0)
  end
end
if #checkconfigs == 1 and
   checkconfigs[1] ~= stdconfig and
   (options["target"] == "check" or options["target"] == "save") then
   local config = "./" .. checkconfigs[1] .. ".lua"
   if fileexists(config) then
     dofile(config)
   else
     print("Error: Cannot find configuration " ..  checkconfigs[1])
     exit(1)
   end
end

-- Call the main function after filtering special cases
if options["target"] == "help" then
  help()
  exit(0)
elseif options["target"] == "version" then
  version()
  exit(0)
end

main(options["target"], options["names"])

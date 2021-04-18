using Pkg;
Pkg.add("HTTP")
Pkg.add("JSON")
using JSON
config = JSON.parsefile("./config.json")
for dep in config["Dependencies"]
  Pkg.add(dep)
end
Pkg.precompile()

import Pkg

Pkg.add(["PackageCompiler", "JSON"])

using PackageCompiler
using JSON

runtime_url = "https://github.com/harris-chris/julia-lambda-runtime"
runtime_url_branch = "master"
image_runtime_dir = ARGS[1]
package = ARGS[2]
dependencies_json = ARGS[3]
cpu_target = ARGS[4]
precompile_file = "precompile_runtime.jl"

Pkg.add(url=runtime_url, rev=runtime_url_branch)
dependencies_arr = JSON.parse(dependencies_json)
for dep in dependencies_arr
  Pkg.add(dep)
end
Pkg.precompile()
#Pkg.activate()

if package == "true"
  create_sysimage(
                  :JuliaLambdaRuntime, 
                  precompile_execution_file=precompile_file,
                  replace_default=true,
                  cpu_target=cpu_target,
                 )
end

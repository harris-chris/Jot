# IMPORTS
import SimpleContainerGenerator
using ArgParse, JSON

# EXCEPTIONS
struct InterpolationNotFoundException <: Exception 
  interpolation::String
end

# GLOBALS
@Base.kwdef struct Builtins
  scripts_path::String
  image_path::String
  function_path::String
  template_path::String
  source_files_path::String
  special_folder_names::Array{String}
  default_config_path::String
  script_templates_path::String
end

const builtins = Builtins(
  scripts_path = "./scripts",
  image_path = "./image",
  function_path = "./function",
  template_path = "./template",
  source_files_path = "./template/image",
  special_folder_names = ["_runtime", "_depot"],
  default_config_path = "./config.json",
  script_templates_path = "./template/scripts",
)

# CODE
function parse_commandline() 
  s = ArgParseSettings(
    "A utility to create Julia docker containers for use in AWS Lambda",
    version="1.0.0",
    autofix_names=true,
  )

  @add_arg_table s begin
    "--config-file", "-c"
      help = "Path to configuration file to use for build"
      default = "$(builtins.default_config_path)"
    "buildfilesonly"
      help = "Create build files only (in $(builtins.scripts_path)) from the configuration file and Dockerfile_template"
      action = :command
    "buildimage"
      help = "Build a docker image from the configuration file and Dockerfile_template"
      action = :command
  end
  parse_args(s)
end

@Base.kwdef struct AWSConfig
  account_id::String
  region::String
  role::String
end

@Base.kwdef struct ImageConfig
  name::String
  tag::String
  dependencies::Array{String}
  base::String
  runtime_path::String
  julia_depot_path::String
end

@Base.kwdef struct LambdaFunctionConfig
  name::String
  timeout::Int
  memory_size::Int
end

@Base.kwdef struct Config
  aws::AWSConfig
  image::ImageConfig
  lambda_function::LambdaFunctionConfig
  file_path::String
end

function create_config(
    config_fpath::String,
  )::Config
  file_cfg = JSON.parsefile(config_fpath)

  # flatten the configuration keys
  cfg = merge(values(file_cfg)...)

  aws_config = AWSConfig(
    account_id=cfg["account_id"], 
    region=cfg["region"],
    role=cfg["role"],
  )

  image_config = ImageConfig(
    name=cfg["name"], 
    tag=cfg["tag"], 
    dependencies=cfg["dependencies"], 
    base=cfg["base"], 
    julia_depot_path=cfg["julia_depot_path"], 
    runtime_path=cfg["runtime_path"], 
  )

  lambda_function_config = LambdaFunctionConfig(
    name=cfg["name"], 
    timeout=cfg["timeout"], 
    memory_size=cfg["memory_size"],
  )

  Config(
   aws=aws_config, 
   image=image_config, 
   lambda_function=lambda_function_config,
   file_path=config_fpath,
  )
end

function get_image_name(config::Config)::String
  "$(config.aws.account_id).dkr.ecr.$(config.aws.region).amazonaws.com/$(config.image.name):$(config.image.tag)"
end


function interpolate_string_with_config(
    str::String,
    config::Config,
  )::String
  mappings = Dict(
    raw"$(aws.account_id)" => config.aws.account_id,
    raw"$(aws.region)" => config.aws.region,
    raw"$(aws.role)" => config.aws.role,
    raw"$(image.name)" => config.image.name,
    raw"$(image.tag)" => config.image.tag,
    raw"$(image.base)" => config.image.base,
    raw"$(image.runtime_path)" => config.image.runtime_path,
    raw"$(image.julia_depot_path)" => config.image.julia_depot_path,
    raw"$(image.full_image_string)" => get_image_name(config),
    raw"$(lambda_function.name)" => config.lambda_function.name,
    raw"$(lambda_function.timeout)" => config.lambda_function.timeout,
    raw"$(lambda_function.memory_size)" => config.lambda_function.memory_size,
  )
  aws_matches = map(x -> x.match, eachmatch(r"\$\(aws.[a-z\_]+\)", str))
  image_matches = map(x -> x.match, eachmatch(r"\$\(image.[a-z\_]+\)", str))
  lambda_function_matches = map(x -> x.match, eachmatch(r"\$\(lambda_function.[a-z\_]+\)", str))
  all_matches = [aws_matches ; image_matches ; lambda_function_matches]

  for var_match in all_matches 
    try 
      str = replace(str, var_match => mappings[var_match])
    catch e
      if isa(e, KeyError)
        throw(InterpolationNotFoundException(var_match))
      end
    end
  end
  str
end

function copy_template()
  tmp = builtins.template_path
  dirs = filter(
                x -> isdir(joinpath(tmp, x)),
                readdir(builtins.template_path)
               )
  foreach(dir -> run(`rm -rf $dir`), dirs)
  foreach(dir -> run(`cp $tmp/$dir ./ -r`), dirs)
end

function copy_function(config::Config)
  func = builtins.function_path
  runtime = "$(builtins.image_path)$(config.image.runtime_path)"
  run(`cp $func/. $runtime -r`)
end

function map_special_folder(name::String, config::Config)::String
  mappings = Dict(
    "_runtime" => config.image.runtime_path,
    "_depot" => config.image.julia_depot_path,
  )
  mappings[name]
end

function replace_special_directories(path::String, config::Config)
  to_delete = []
  for (root, dirs, files) in walkdir(path)
    for dir in dirs
      if dir in builtins.special_folder_names
        orig_path = joinpath(root, dir)
        new_path = joinpath(root, map_special_folder(dir, config)[2:end])
        run(`mkdir -p $new_path`)
        run(`cp $orig_path/. $new_path -r`)
        push!(to_delete, orig_path)
      end
    end
  end
  foreach(special -> run(`rm -r $special`), to_delete)
end

function interpolate_scripts(path::String, config::Config)
  for (root, dirs, files) in walkdir(path)
    for file in files
      fname = joinpath(root, file)
      interpolated::Union{Nothing, String} = open(fname, "r") do f
        contents = read(f, String)
        if contents[1:2] == "#!"
          interp = try 
            interpolate_string_with_config(contents, config)
          catch e
            if isa(e, InterpolationNotFoundException)
              error("Unable to recognize interpolation $(e.interpolation) in $fname")
            else 
              rethrow()
            end
          end
        else
          interp = nothing
        end
      end
      if !isnothing(interpolated) 
        open(fname, "w") do f
          write(f, interpolated)
        end
      end
    end
  end
end

function dockerfile_add_julia_image(config::Config)::String
  """
  FROM julia:$(config.image.base)
  """
end

function dockerfile_runtime_files(config::Config)::String
  """
  RUN mkdir -p $(config.image.julia_depot_path)
  ENV JULIA_DEPOT_PATH=$(config.image.julia_depot_path)
  COPY .$(config.image.julia_depot_path)/. $(config.image.julia_depot_path)

  RUN mkdir -p $(config.image.runtime_path)
  WORKDIR $(config.image.runtime_path)

  # COPY $(config.file_path) ./
  COPY $(config.image.runtime_path)/. ./

  ENV PATH="$(config.image.runtime_path):\${PATH}"

  ENTRYPOINT ["$(config.image.runtime_path)/bootstrap"]
  """
end

function dockerfile_dependencies_and_precompile(config::Config)::String
  required_packages = ["HTTP", "JSON"]
  deps = ""
  for dep in [required_packages; config.image.dependencies]
    deps = deps * "\\\"$dep\\\","
  end
  println(deps)
  """
  RUN julia --startup-file=no -e "using Pkg; Pkg.add([$deps]); Pkg.precompile();"
  """
end

function build_packaged_dockerfile(config::Config)

end

function build_standard_dockerfile(config::Config)
  contents = foldl(
    *, [
    dockerfile_add_julia_image(config),
    dockerfile_runtime_files(config),
    dockerfile_dependencies_and_precompile(config),
  ]; init = "")
  open("$(builtins.image_path)/Dockerfile", "w") do dockerfile
    write(dockerfile, contents)
  end
end

function build_dockerfile_script(config::Config)
  contents = """
  #!/bin/bash
  DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  docker build \\
    --rm \\
    --tag $(get_image_name(config)) \\
    \$DIR/.
  """
  open("$(builtins.image_path)/build_image.sh", "w") do build_script
    write(build_script, contents)
  end
end

function give_runtime_execution_permissions(config::Config)
  img = builtins.image_path
  runtime = config.image.runtime_path
  run(`chmod +x -R $img$runtime`)
end

function main()
  parsed_args = parse_commandline()
  config_fpath = parsed_args["config_file"]
  
  if parsed_args["%COMMAND%"] in ["buildfilesonly", "buildimage"]
    config = create_config(config_fpath)
    println("Configuration parsed")

    copy_template()
    replace_special_directories(builtins.image_path, config)
    interpolate_scripts(builtins.image_path, config)
    interpolate_scripts(builtins.scripts_path, config)
    give_runtime_execution_permissions(config)

    copy_function(config)

    build_standard_dockerfile(config)
    build_dockerfile_script(config)
    println("Dockerfile created")
  end
  if parsed_args["%COMMAND%"] == "buildimage"
    run(`bash $(builtins.image_path)/build_image.sh`)
  end
end

main()

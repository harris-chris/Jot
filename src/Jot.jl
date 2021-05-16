import Pkg
Pkg.activate(pwd())
Pkg.instantiate()

module Jot

# IMPORTS
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
  required_packages::Array{String}
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
  required_packages = ["HTTP", "JSON"],
)

# CODE
function parse_commandline(args) 
  s = ArgParseSettings(
    "A utility to create Julia docker containers for use in AWS Lambda",
    version="1.0.0",
    autofix_names=true,
  )

  @add_arg_table s begin
    "--config-file", "-c"
      help = "Path to configuration file to use for build"
      default = "$(builtins.default_config_path)"
    "--packaged", "-p"
      help = "Use PackageCompiler to create Docker image; increases build times but decreases function response times in AWS Lambda"
      action = :store_true
    "--no-cache"
      help = "Construct the docker image without using existing cache, eg from scratch"
      action = :store_true
    "buildimage"
      help = "Build a docker image from the configuration file and Dockerfile_template"
      action = :command
    "buildfilesonly"
      help = "Create build files only (in $(builtins.scripts_path)) from the configuration file and Dockerfile_template"
      action = :command
    "getdefaultconfig"
      help = "Create a default configuration file, default_config.json"
      action = :command
  end
  parse_args(args, s)
end

@Base.kwdef struct AWSConfig
  account_id::String
  region::String
  role::String
end

JSON.lower(aws::AWSConfig) = Dict(
                                  "account_id" => aws.account_id,
                                  "region" => aws.region,
                                  "role" => aws.role
                                 )

@Base.kwdef struct ImageConfig
  name::String
  tag::String
  dependencies::Array{String}
  base::String
  runtime_path::String
  julia_depot_path::String
  julia_cpu_target::String
end

JSON.lower(image::ImageConfig) = Dict(
                                  "name" => image.name,
                                  "tag" => image.tag,
                                  "dependencies" => image.dependencies,
                                  "base" => image.base,
                                  "runtime_path" => image.runtime_path,
                                  "julia_depot_path" => image.julia_depot_path,
                                  "julia_cpu_target" => image.julia_cpu_target,
                                 )

@Base.kwdef struct LambdaFunctionConfig
  name::String
  timeout::Int
  memory_size::Int
end

JSON.lower(lambda::LambdaFunctionConfig) = Dict(
                                  "name" => lambda.name,
                                  "timeout" => lambda.timeout,
                                  "memory_size" => lambda.memory_size,
                                 )

@Base.kwdef struct Config
  aws::AWSConfig
  image::ImageConfig
  lambda_function::LambdaFunctionConfig
end

JSON.lower(config::Config) = Dict(
                                  "aws" => JSON.lower(config.aws),
                                  "image" => JSON.lower(config.image),
                                  "lambda_function" => JSON.lower(config.lambda_function),
                                 )

function read_config_file(config_fpath::String)::Dict{String, Dict{String, Any}}
  JSON.parsefile(config_fpath)
end

function create_config(
    config_json::Dict{String, Dict{String, Any}},
    config_fpath::String,
  )::Config

  # flatten the configuration keys
  cfg = merge(values(config_json)...)

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
    julia_cpu_target=cfg["julia_cpu_target"]
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
  )
end

function get_default_config(prefix::String="")::Config
  prefix = prefix == "" ? "" : prefix * "-" 
  Config(
    aws = AWSConfig(
      account_id = "123456789012",
      region = "ap-northeast-1",
      role = prefix * "LambdaExecutionRole",
    ),
    image = ImageConfig(
      name = prefix * "julia-lambda",
      tag = "latest",
      base = "1.6.0",
      dependencies = [],
      runtime_path = "/var/runtime",
      julia_depot_path = "/var/julia",
      julia_cpu_target = "x86-64",
    ),
    lambda_function = LambdaFunctionConfig(
      name = prefix * "julia-function",
      timeout = 30,
      memory_size = 1000,
    )
  )
end

function generate_default_config_file()
  default_config = get_default_config()
  open("default_config.json", "w") do f
    JSON.print(f, default_config, 4)
  end
end

function get_image_uri_string(config::Config)::String
  "$(config.aws.account_id).dkr.ecr.$(config.aws.region).amazonaws.com/$(config.image.name):$(config.image.tag)"
end

function get_role_arn_string(config::Config)::String
  "arn:aws:iam::$(config.aws.account_id):role/$(config.aws.role)"
end

function get_function_uri_string(config::Config)::String
  "$(config.aws.account_id).dkr.ecr.$(config.aws.region).amazonaws.com/$(config.image.name)"
end

function get_function_arn_string(config::Config)::String
  "arn:aws:lambda:$(config.aws.region):$(config.aws.account_id):function:$(config.lambda_function.name)"
end

function get_ecr_arn_string(config::Config)::String
  "arn:aws:ecr:$(config.aws.region):$(config.aws.account_id):repository/$(config.lambda_function.name)"
end

function get_ecr_uri_string(config::Config)::String
  "$(config.aws.account_id).dkr.ecr.$(config.aws.region).amazonaws.com/$(config.lambda_function.name)"
end

function interpolate_string_with_config(
    str::String,
    config::Config,
  )::String
  mappings = Dict(
    raw"$(aws.account_id)" => config.aws.account_id,
    raw"$(aws.region)" => config.aws.region,
    raw"$(aws.role)" => config.aws.role,
    raw"$(aws.role_arn_string)" => get_role_arn_string(config),
    raw"$(image.name)" => config.image.name,
    raw"$(image.tag)" => config.image.tag,
    raw"$(image.base)" => config.image.base,
    raw"$(image.runtime_path)" => config.image.runtime_path,
    raw"$(image.julia_depot_path)" => config.image.julia_depot_path,
    raw"$(image.julia_cpu_target)" => config.image.julia_cpu_target,
    raw"$(image.image_uri_string)" => get_image_uri_string(config),
    raw"$(image.ecr_arn_string)" => get_ecr_arn_string(config),
    raw"$(image.ecr_uri_string)" => get_ecr_uri_string(config),
    raw"$(image.function_uri_string)" => get_function_uri_string(config),
    raw"$(image.function_arn_string)" => get_function_arn_string(config),
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

function dockerfile_add_utilities()::String
  """
  RUN apt-get update && apt-get install -y \\
    gcc
  """
end

function dockerfile_runtime_files(config::Config, package::Bool)::String
  """
  RUN mkdir -p $(config.image.julia_depot_path)
  ENV JULIA_DEPOT_PATH=$(config.image.julia_depot_path)
  COPY .$(config.image.julia_depot_path)/. $(config.image.julia_depot_path)

  RUN mkdir -p $(config.image.runtime_path)
  WORKDIR $(config.image.runtime_path)

  # COPY $(config.file_path) ./
  COPY $(config.image.runtime_path)/. ./
  RUN julia build_runtime.jl $(config.image.runtime_path) $package $(get_dependencies_json(config)) $(config.image.julia_cpu_target)

  ENV PATH="$(config.image.runtime_path):\${PATH}"

  ENTRYPOINT ["$(config.image.runtime_path)/bootstrap"]
  """
end

function dockerfile_add_permissions(config::Config)::String
  """
  RUN chmod +x -R $(config.image.runtime_path)
  RUN chmod +x -R $(config.image.julia_depot_path)
  """
end

function get_dependencies_json(config::Config)::String
  # all_deps = [builtins.required_packages; config.image.dependencies]
  all_deps = config.image.dependencies
  all_deps_string = ["\"$dep\"" for dep in all_deps]
  json(all_deps)
end

function build_standard_dockerfile(config::Config, package::Bool)
  contents = foldl(
    *, [
    dockerfile_add_julia_image(config),
    dockerfile_add_utilities(),
    dockerfile_runtime_files(config, package),
    dockerfile_add_permissions(config),
  ]; init = "")
  open("$(builtins.image_path)/Dockerfile", "w") do dockerfile
    write(dockerfile, contents)
  end
end

function build_dockerfile_script(config::Config, no_cache::Bool)
  contents = """
  #!/bin/bash
  DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  docker build \\
    --rm $(no_cache ? "--no-cache" : "") \\
    --tag $(get_image_uri_string(config)) \\
    \$DIR/.
  """
  open("$(builtins.image_path)/build_image.sh", "w") do build_script
    write(build_script, contents)
  end
end

function give_necessary_permissions(config::Config)
  img = builtins.image_path
  runtime = config.image.runtime_path
  depot = config.image.julia_depot_path
  run(`chmod +x -R $img$runtime`)
  run(`chmod +x -R $img$depot`)
end

function main(args)
  parsed_args = parse_commandline(args)
  config_fpath = parsed_args["config_file"]
  command = parsed_args["%COMMAND%"]
  if command == "getdefaultconfig"
    generate_default_config_file()
  elseif command in ["buildfilesonly", "buildimage"]
    config_json = read_config_file(config_fpath)
    config = create_config(config_json, config_fpath)
    println("Configuration parsed")

    copy_template()
    replace_special_directories(builtins.image_path, config)
    interpolate_scripts(builtins.image_path, config)
    interpolate_scripts(builtins.scripts_path, config)
    println("./scripts built")
    give_necessary_permissions(config)
    println("./image built")

    copy_function(config)

    build_standard_dockerfile(config, parsed_args["packaged"])
    build_dockerfile_script(config, parsed_args["no_cache"])
    println("Dockerfile created")
  end
  if parsed_args["%COMMAND%"] == "buildimage"
    run(`bash $(builtins.image_path)/build_image.sh`)
  end
end

end # module

Jot.main(ARGS)


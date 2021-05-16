using Jot
using Test
import Random

main_image_path = joinpath("..", Jot.builtins.image_path)
main_scripts_path = joinpath("..", Jot.builtins.scripts_path)

run(`mkdir -p test_build/function`)
run(`cp ../function/. test_build/function -r`)

run(`mkdir -p test_build/image`)
run(`cp ../image/. test_build/image -r`)

run(`mkdir -p test_build/template`)
run(`cp ../template/. test_build/template -r`)

run(`mkdir -p test_build/scripts`)
run(`cp ../scripts/. test_build/scripts -r`)

@testset "Create a random lambda" begin
  cd(joinpath(pwd(), "test_build"))
  @info pwd()
  prefix = lowercase(Random.randstring(10))
  config = Jot.get_default_config(prefix, Dict("aws.account_id" => "513118378795"))
  parsed_args = Jot.parse_commandline(["buildimage"])
  command = pop!(parsed_args, "%COMMAND%")
  Jot.main(command, parsed_args, config)
  @test true
end


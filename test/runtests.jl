using Jot
using Test
import Random

const test_build_dir = "test_build"

function make_test_build()
  run(`rm -rf $test_build_dir`)
  run(`mkdir -p $test_build_dir/function`)
  run(`cp ../function/. $test_build_dir/function -r`)

  run(`mkdir -p $test_build_dir/image`)
  run(`cp ../image/. $test_build_dir/image -r`)

  run(`mkdir -p $test_build_dir/template`)
  run(`cp ../template/. $test_build_dir/template -r`)

  run(`mkdir -p $test_build_dir/scripts`)
  run(`cp ../scripts/. $test_build_dir/scripts -r`)
end

@testset "Create a random lambda" begin
  make_test_build()
  cd(joinpath(pwd(), test_build_dir))

  # Generate random prefix
  prefix = lowercase(Random.randstring(10))
  config = Jot.get_default_config(prefix, Dict("aws.account_id" => "513118378795"))
  parsed_args = Jot.parse_commandline(["buildimage"])
  command = pop!(parsed_args, "%COMMAND%")
  Jot.main(command, parsed_args, config, pwd())
  @test run(`scripts/run_local_test.sh`) == 0
end


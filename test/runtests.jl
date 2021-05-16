using Jot
using Test
import Random

@testset "Create a random lambda" begin
  prefix = Random.randstring(10) 
  test_config = get_default_config(prefix)
    
  @test true
end


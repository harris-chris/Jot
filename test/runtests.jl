using Jot
using Test
import Random

@testset "Create a random lambda" begin
  prefix = Random.randstring(10) 
  test_config = Jot.get_default_config(prefix)
  main("getdefaultconfig", Dict(), test_config)  
  @test true
end


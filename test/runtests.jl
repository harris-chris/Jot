using Test
import Random

@testset "Create a random lambda" begin
  prefix = Random.randstring(10) 
    
  @test true
end

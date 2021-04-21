using JuliaLambdaRuntime
using JSON

try 
  start_runtime("127.0.0.1:9001")
catch e end

Base.@kwdef struct Invocation
  body::Any
  aws_request_id::String
  deadline_ms::Int
  invoked_function_arn::String
  trace_id::String
end

invocation_body = json(Dict("a"=>1, "b"=>3, "operator"=>"+"))

test_invoc = JuliaLambdaRuntime.Invocation(
                                           body=invocation_body,
                                           aws_request_id="EXAMPLE",
                                           deadline_ms=20000,
                                           invoked_function_arn="EXAMPLE",
                                           trace_id="EXAMPLE"
                                          )

try
  JuliaLambdaRuntime.react_to_invocation(test_invoc)
catch e end

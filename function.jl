Base.@kwdef struct Invocation
  body::Any
  aws_request_id::String
  deadline_ms::Int
  invoked_function_arn::String
  trace_id::String
end

Base.@kwdef struct InvocationResponse
  response::Any
end

Base.@kwdef struct InvocationError
  errorMessage::String
  errorType::String
end

function react_to_invocation(inv::Invocation)::Union{InvocationResponse, InvocationError}
  # Your code goes here
  try
    what_should_we_return = inv.body["What should I return?"]
    if what_should_we_return == "Success"
      return InvocationResponse("SUCCESS")
    else
      return InvocationResponse("$(what_should_we_return) was not a success")
    end
  catch e
    return InvocationError("Key not found", "KeyError")
  end
end

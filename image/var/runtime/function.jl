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
    the_answer = inv.body["3 * 3?"]
    if the_answer == 9
      return InvocationResponse("Indeed.")
    else
      return InvocationResponse("3 * 3 != $the_answer")
    end
  catch e
    return InvocationError("Key not found", "KeyError")
  end
end

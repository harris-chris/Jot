using JSON

Base.@kwdef struct Invocation
  body::Any
  aws_request_id::String
  deadline_ms::Int
  invoked_function_arn::String
  trace_id::String
end

Base.@kwdef struct InvocationResponse
  response::String
end

Base.@kwdef struct InvocationError
  errorType::String
  errorMessage::String
end

function InvocationError(e::Exception)::InvocationError
  e_type = string(typeof(e))
  if hasproperty(e, :msg)
    e_message = e.msg
  else
    e_message = "Error"
  end
  InvocationError(e_type, e_message)
end

function react_to_invocation(inv::Invocation)::Union{InvocationResponse, InvocationError}
  # Your code goes here - example below!
  try
    num_a = inv.body["a"]
    num_b = inv.body["b"]
    op = inv.body["operation"]
    response = nothing
    if op == "+"
      response = num_a + num_b
    elseif op == "-"
      response = num_a - num_b
    end
    if isnothing(response)
      return InvocationError("Error", "Unable to execute $num_a $op $num_b")
    else 
      return InvocationResponse(json(response)) # Note the response must be a JSON
    end
  catch e
    return InvocationError(e)
  end
end

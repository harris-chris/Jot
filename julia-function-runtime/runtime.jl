using HTTP, JSON

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

function main(host)
  endpoint = "http://$(host)/2018-06-01/runtime/invocation/"

  while true
    http = HTTP.request("GET", "$(endpoint)next"; verbose=3)
    body = JSON.parse(String(http.body))
    invocation = Invocation(
      body=body,
      aws_request_id=HTTP.header(http, "Lambda-Runtime-Aws-Request-Id"),
      deadline_ms=parse(Int, HTTP.header(http, "Lambda-Runtime-Deadline-Ms")),
      invoked_function_arn=HTTP.header(http, "Lambda-Runtime-Invoked-Function-Arn"),
      trace_id=HTTP.header(http, "Lambda-Runtime-Trace-Id"),
    )

    reaction = react_to_invocation(invocation)
    process_reaction(reaction, invocation.aws_request_id, endpoint)
  end
end

# Add your code here. It can either return an InvocationResponse, or an InvocationError.
function react_to_invocation(inv::Invocation)::Union{InvocationResponse, InvocationError}
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

function process_reaction(reaction::InvocationResponse, aws_request_id::String, endpoint::String)
  response = HTTP.request(
    "POST", 
    "$(endpoint)$(aws_request_id)/response", 
    [], 
    reaction.response
  )
end

function process_reaction(reaction::InvocationError, aws_request_id::String, endpoint::String)
  response = HTTP.request(
    "POST", 
    "$(endpoint)$(aws_request_id)/error", 
    [("Lambda-Runtime-Function-Error-Type", "Unhandled")], 
    json(reaction),
  )
end

main(ARGS[1])

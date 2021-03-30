ARG FUNCTION_DIR="/function"

FROM julia:1.5

ARG FUNCTION_DIR="/function"
RUN mkdir -p ${FUNCTION_DIR}
COPY app/* ${FUNCTION_DIR}

RUN apt-get update && apt-get install -y curl nmap
RUN julia -e "using Pkg; Pkg.add([\"HTTP\"])"

ENV PATH=/root/.julia/conda/3/bin:$PATH

ENTRYPOINT ["julia", "/function/runtime.jl"]

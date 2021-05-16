FROM julia:1.6.0
RUN apt-get update && apt-get install -y \
  gcc
RUN mkdir -p /var/julia
ENV JULIA_DEPOT_PATH=/var/julia
COPY ./var/julia/. /var/julia

RUN mkdir -p /var/runtime
WORKDIR /var/runtime

COPY /var/runtime/. ./
RUN julia build_runtime.jl /var/runtime false [] x86-64

ENV PATH="/var/runtime:${PATH}"

ENTRYPOINT ["/var/runtime/bootstrap"]
RUN chmod +x -R /var/runtime
RUN chmod +x -R /var/julia

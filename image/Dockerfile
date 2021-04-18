FROM julia:1.6.0
RUN mkdir -p /var/julia
ENV JULIA_DEPOT_PATH=/var/julia
COPY ./var/julia/. /var/julia

RUN mkdir -p /var/runtime
WORKDIR /var/runtime

# COPY ./config.json ./
COPY /var/runtime/. ./

ENV PATH="/var/runtime:${PATH}"

ENTRYPOINT ["/var/runtime/bootstrap"]
RUN julia --startup-file=no -e "using Pkg; Pkg.add([\"HTTP\",\"JSON\",]); Pkg.precompile();"

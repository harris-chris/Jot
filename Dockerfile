FROM julia:1.6

RUN mkdir -p /var/runtime
RUN mkdir -p /var/julia
ENV JULIA_DEPOT_PATH=/var/julia
WORKDIR /var/runtime

COPY julia-function-runtime/* ./
COPY image_build/startup.jl $JULIA_DEPOT_PATH
COPY image_build/dependencies.jl ./
COPY image_build/bootstrap ./
COPY config.json ./
COPY aws-lambda-rie /usr/local/bin/aws-lambda-rie

RUN /usr/local/julia/bin/julia --startup-file=no dependencies.jl

ENTRYPOINT ["/var/runtime/bootstrap"]

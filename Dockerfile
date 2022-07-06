ARG PROJECT

FROM ubuntu:20.04 as plotlablib_requirements_base

ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"

RUN mkdir -p /tmp/${PROJECT}/files
COPY files/${REQUIREMENTS_FILE} /tmp/${PROJECT}/files
WORKDIR /tmp/${PROJECT}/files

RUN apt-get update && \
    apt-get install --no-install-recommends -y checkinstall && \
    DEBIAN_FRONTEND=noninteractive xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

COPY . /tmp/${PROJECT}
COPY --from=libzmq /tmp/libzmq /tmp/libzmq
COPY --from=cppzmq /tmp/cppzmq /tmp/cppzmq

WORKDIR /tmp/libzmq/build
RUN cmake --install .

WORKDIR /tmp/cppzmq/build
RUN cmake --install .

FROM plotlablib_requirements_base AS plotlablib_builder

WORKDIR /tmp/${PROJECT}/${PROJECT}
RUN rm -rf build && \
    bash build.sh 


#FROM alpine:3.14 AS plotlablib_package

#COPY --from=plotlablib_builder /tmp/${PROJECT} /tmp/${PROJECT}

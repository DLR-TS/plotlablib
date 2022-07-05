
FROM libzmq:latest AS libzmq
FROM cppzmq:latest AS cppzmq

FROM ubuntu:20.04 as plotlablib_requirements_base

ARG REQUIREMENTS_FILE="requirements.plotlab.ubuntu20.04.system"


RUN mkdir -p /tmp/plotlablib/files
COPY files/${REQUIREMENTS_FILE} /tmp/plotlablib/files
WORKDIR /tmp/plotlablib/files

RUN apt-get update && xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

#COPY --from=libzmq /tmp/libzmq/build/*.deb .
#SHELL ["/bin/bash", "-c"]
#RUN dpkg -i *.deb 

COPY . /tmp/plotlablib
COPY --from=libzmq /tmp/libzmq /tmp/plotlab/lib/external/libzmq/libzmq
COPY --from=cppzmq /tmp/cppzmq /tmp/plotlab/lib/external/cppzmq/cppzmq
RUN ln -s /tmp/plotlab/plotlablib/external/libzmq/libzmq /tmp/libzmq
RUN ln -s /tmp/plotlab/plotlablib/external/cppzmq/cppzmq /tmp/cppzmq

WORKDIR /tmp/libzmq/build
RUN cmake --install .

WORKDIR /tmp/cppzmq/build
RUN cmake --install .

FROM plotlablib_requirements_base AS plotlablib_builder

WORKDIR /tmp/plotlablib
RUN rm -rf /tmp/plotlablib/plotlablib/build && \
    make build_plotlablib

WORKDIR /tmp/libzmq/build
RUN cmake --install . --prefix /tmp/plotlab/lib/build/install
WORKDIR /tmp/cppzmq/build
RUN cmake --install . --prefix /tmp/plotlab/lib/build/install

FROM alpine:3.14 AS plotlab_package

COPY --from=plotlab_builder /tmp/plotlab /tmp/plotlab

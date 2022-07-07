ARG PROJECT

FROM libzmq:latest AS libzmq
FROM cppzmq:latest AS cppzmq

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
RUN mkdir -p /tmp/${PROJECT}/${PROJECT}/external/libzmq
WORKDIR /tmp/${PROJECT}/${PROJECT}/external/libzmq
RUN ln -s ../../../../libzmq libzmq

COPY --from=cppzmq /tmp/cppzmq /tmp/cppzmq
RUN mkdir -p /tmp/${PROJECT}/${PROJECT}/external/cppzmq
WORKDIR /tmp/${PROJECT}/${PROJECT}/external/cppzmq
RUN ln -s ../../../../cppzmq cppzmq

WORKDIR /tmp/libzmq/build
RUN cmake --install . --prefix /tmp/${PROJECT}/${PROJECT}/build/install 
#RUN cmake --install .

WORKDIR /tmp/cppzmq/build
RUN cmake --install . --prefix /tmp/${PROJECT}/${PROJECT}/build/install 
#RUN cmake --install .

FROM plotlablib_requirements_base AS plotlablib_builder

WORKDIR /tmp/${PROJECT}/${PROJECT}
RUN bash build.sh


#FROM alpine:3.14 AS plotlablib_package

#COPY --from=plotlablib_builder /tmp/${PROJECT} /tmp/${PROJECT}

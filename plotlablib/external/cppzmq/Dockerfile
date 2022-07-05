ARG PROJECT

ARG libzmq_install_path

FROM libzmq:latest AS libzmq

FROM ubuntu:20.04 as cppzmq_builder

ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


RUN mkdir -p /tmp/${PROJECT}
COPY files/${REQUIREMENTS_FILE} /tmp/${PROJECT}

WORKDIR /tmp/${PROJECT}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

COPY --from=libzmq /tmp/libzmq /tmp/libzmq
WORKDIR /tmp/libzmq/build
RUN cmake --install .
#RUN cmake --install . --prefix /tmp/${PROJECT}/build/install

COPY ${PROJECT} /tmp/${PROJECT}

RUN mkdir -p /tmp/${PROJECT}/build
WORKDIR /tmp/${PROJECT}/build

RUN cmake .. -DCPPZMQ_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX:PATH=install && \
    cmake --build . --config Release --target install -- -j $(nproc)


FROM alpine:3.14

ARG PROJECT

COPY --from=cppzmq_builder /tmp/${PROJECT} /tmp/${PROJECT}


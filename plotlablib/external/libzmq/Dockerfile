
FROM ubuntu:20.04 as libzmq_builder

ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


RUN mkdir -p /tmp/${PROJECT}
COPY files/requirements.${PROJECT}.ubuntu20.04.system /tmp/${PROJECT}

WORKDIR /tmp/${PROJECT}

RUN apt-get update && \
    apt-get install --no-install-recommends -y checkinstall && \
    DEBIAN_FRONTEND=noninteractive xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

COPY ${PROJECT} /tmp/${PROJECT}

RUN mkdir /tmp/${PROJECT}/build
WORKDIR /tmp/${PROJECT}/build

RUN cmake .. && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cmake --install . --prefix /tmp/${PROJECT}/build/install


FROM alpine:3.14

ARG PROJECT

COPY --from=libzmq_builder /tmp/${PROJECT} /tmp/${PROJECT}


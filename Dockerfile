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

COPY ${PROJECT} /tmp/${PROJECT}/${PROJECT}

FROM plotlablib_requirements_base AS plotlablib_external_library_requirements_base

ARG EXTERNAL_LIBRARY_DIRECTORY=/tmp/${PROJECT}/${PROJECT}/external
ARG INSTALL_PREFIX=/tmp/${PROJECT}/${PROJECT}/build/install
RUN mkdir -p "${INSTALL_PREFIX}"

ARG LIB=libzmq
COPY --from=libzmq /tmp/${LIB} /tmp/${LIB}
WORKDIR /tmp/${LIB}/build
RUN cmake --install . --prefix ${INSTALL_PREFIX}

ARG LIB=cppzmq
COPY --from=cppzmq /tmp/${LIB} /tmp/${LIB}
WORKDIR /tmp/${LIB}/build
RUN cmake --install . --prefix ${INSTALL_PREFIX}


FROM plotlablib_external_library_requirements_base AS plotlablib_builder

ARG PROJECT

WORKDIR /tmp/${PROJECT}/${PROJECT}/build
RUN cmake .. \
             -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX="install" && \ 
    cmake --build . -v --config Release --target install -- -j $(nproc)

RUN cmake .. && cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . || true

RUN mv CMakeCache.txt CMakeCache.txt.build
#FROM alpine:3.14 AS plotlablib_package

#COPY --from=plotlablib_builder /tmp/${PROJECT} /tmp/${PROJECT}

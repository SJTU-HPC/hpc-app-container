#===========================#
# multi-stage: build
#===========================#

FROM chengshenggan/hpc-base-container:ompi-4.0 AS build

# cmake 3.16.3
RUN yum install -y \
        make \
        wget && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://cmake.org/files/v3.16/cmake-3.16.3-Linux-x86_64.sh && \
    mkdir -p /usr/local && \
    /bin/sh /var/tmp/cmake-3.16.3-Linux-x86_64.sh --prefix=/usr/local --skip-license && \
    rm -rf /var/tmp/cmake-3.16.3-Linux-x86_64.sh
ENV PATH=/usr/local/bin:$PATH

# OpenFOAM v8
RUN yum install -y \
        patch \
        flex \
        bison \
        zlib-devel \
        boost-system \
        boost-thread \
        readline-devel \
        ncurses-devel && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /opt && cd /opt && wget -O - http://dl.openfoam.org/source/8 | tar xz && \
    mkdir -p /opt && cd /opt && wget -O - http://dl.openfoam.org/third-party/8 | tar xz && \
    mv OpenFOAM-8-version-8 OpenFOAM-8 && mv ThirdParty-8-version-8 ThirdParty-8 && \
    cd OpenFOAM-8 && \
    sed -i 's,FOAM_INST_DIR=$HOME\/$WM_PROJECT,FOAM_INST_DIR=/opt,g' etc/bashrc && \
    sed -i 's/alias wmUnset/#alias wmUnset/' etc/config.sh/aliases && \
    sed -i '77s/else/#else/' etc/config.sh/aliases && \
    sed -i 's/unalias wmRefresh/#unalias wmRefresh/' etc/config.sh/aliases && \
    source etc/bashrc && \
    ./Allwmake


#===========================#
# multi-stage: install
#===========================#

FROM chengshenggan/hpc-base-container:ompi-4.0
RUN yum install -y \
        zlib-devel \
        boost-system \
        boost-thread \
        readline-devel \
        ncurses-devel && \
    rm -rf /var/cache/yum/*

# OpenFOAM v8
COPY --from=build /opt/OpenFOAM-8 /opt/OpenFOAM-8
COPY --from=build /opt/ThirdParty-8/platforms /opt/ThirdParty-8/platforms

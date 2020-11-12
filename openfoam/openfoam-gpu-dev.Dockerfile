#===========================#
# multi-stage: build
#===========================#

FROM sjtuhpc/hpc-base-container:cuda-10.2.ompi-4.0 AS build

RUN yum install -y \
        epel-release && \
    yum install -y \
        cmake3 \
        make \
        wget && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    rm -rf /var/cache/yum/*

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

FROM sjtuhpc/hpc-base-container:cuda-10.2.ompi-4.0
RUN yum install -y \
        epel-release && \
    yum install -y \
        cmake3 \
        make \
        wget \
        git \
        zlib-devel \
        boost-system \
        boost-thread \
        readline-devel \
        ncurses-devel && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    rm -rf /var/cache/yum/* && \
    /bin/rm /bin/sh && \
    /bin/ln -s /bin/bash /bin/sh

# OpenFOAM v8
COPY --from=build /opt/OpenFOAM-8 /opt/OpenFOAM-8
COPY --from=build /opt/ThirdParty-8/platforms /opt/ThirdParty-8/platforms

ENTRYPOINT [ "sh", "-c", ". /opt/OpenFOAM-8/etc/bashrc && \"$@\"", "-s" ]

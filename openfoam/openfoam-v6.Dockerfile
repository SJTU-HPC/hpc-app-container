#===========================#
# multi-stage: build
#===========================#

FROM chengshenggan/hpc-base-container:ompi-4.0 AS build

RUN yum install -y \
        epel-release && \
    yum install -y \
        cmake3 \
        make \
        wget && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    rm -rf /var/cache/yum/*

# OpenFOAM v6
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
RUN mkdir -p /opt && cd /opt && wget -O - http://dl.openfoam.org/source/6 | tar xz && \
    mkdir -p /opt && cd /opt && wget -O - http://dl.openfoam.org/third-party/6 | tar xz && \
    mv OpenFOAM-6-version-6 OpenFOAM-6 && mv ThirdParty-6-version-6 ThirdParty-6
RUN cd /opt/ThirdParty-6 && rm -rf ./scotch_6.0.3 && \
    wget https://gforge.inria.fr/frs/download.php/file/37622/scotch_6.0.6.tar.gz && \
    tar xf ./scotch_6.0.6.tar.gz && mv ./scotch_6.0.6 ./scotch_6.0.3
RUN source /opt/OpenFOAM-6/etc/bashrc && \
    cd /opt/OpenFOAM-6 && \
    sed -i 's,FOAM_INST_DIR=$HOME\/$WM_PROJECT,FOAM_INST_DIR=/opt,g' etc/bashrc && \
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
    rm -rf /var/cache/yum/* && \
    /bin/rm /bin/sh && \
    /bin/ln -s /bin/bash /bin/sh

# OpenFOAM v8
COPY --from=build /opt/OpenFOAM-6 /opt/OpenFOAM-6
COPY --from=build /opt/ThirdParty-6/platforms /opt/ThirdParty-6/platforms

ENTRYPOINT [ "sh", "-c", ". /opt/OpenFOAM-6/etc/bashrc && \"$@\"", "-s" ]

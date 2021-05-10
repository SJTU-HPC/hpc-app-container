From sjtuhpc/hpc-base-container:gcc-8.ompi-4.0 AS build

# cmake 
RUN yum install -y \
        epel-release &&\
    yum install -y \
        cmake3 \
        make \
        wget \
        git &&\
    ln -s /usr/bin/cmake3 /usr/bin/cmake &&\
    rm -rf /var/cache/yum/*


# hypre  2.20.0 
RUN mkdir hypre_install &&\
    cd hypre_install &&\
    git clone https://github.com/hypre-space/hypre.git &&\
    cd hypre/src/ &&\
    CC=mpicc CXX=mpicxx ./configure --prefix=/usr/local/hypre \
    --with-MPI-include=/usr/local/openmpi/include \
    --with-MPI-lib-dirs=/usr/local/openmpi/lib &&\
    cd cmbuild &&\
    cmake .. &&\
    make install &&\
    cd .. &&\
    make test 

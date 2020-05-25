#===========================#
# multi-stage: build
#===========================#
FROM chengshenggan/hpc-base-container:gcc-8.cuda-10.2.ompi-4.0 AS build

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

# Gromacs version 2020
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://ftp.gromacs.org/pub/gromacs/gromacs-2020.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/gromacs-2020.tar.gz -C /var/tmp -z && \
    mkdir -p /var/tmp/gromacs-2020/build && cd /var/tmp/gromacs-2020/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gromacs -D CMAKE_BUILD_TYPE=Release -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
          -D GMX_BUILD_OWN_FFTW=ON -D GMX_GPU=ON -D GMX_MPI=ON -D GMX_OPENMP=ON \
          -D GMX_PREFER_STATIC_LIBS=ON /var/tmp/gromacs-2020 && \
    cmake --build /var/tmp/gromacs-2020/build --target all -- -j$(nproc) && \
    cmake --build /var/tmp/gromacs-2020/build --target install -- -j$(nproc) && \
    rm -rf /var/tmp/gromacs-2020 /var/tmp/gromacs-2020.tar.gz
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM chengshenggan/hpc-base-container:gcc-8.cuda-10.2.ompi-4.0

# Gromacs version 2020
COPY --from=build /opt/gromacs /opt/gromacs
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH
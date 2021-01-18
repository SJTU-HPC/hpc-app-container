#===========================#
# multi-stage: build
#===========================#
FROM sjtuhpc/hpc-base-container:gcc-8.cuda-10.2.ompi-4.0 AS build

RUN yum install -y \
        epel-release && \
    yum install -y \
        cmake3 \
        make \
        wget && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    rm -rf /var/cache/yum/*

# Gromacs version 2020
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://ftp.gromacs.org/pub/gromacs/gromacs-2019.6.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/gromacs-2019.6.tar.gz -C /var/tmp -z && \
    mkdir -p /var/tmp/gromacs-2019.6/build && cd /var/tmp/gromacs-2019.6/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gromacs -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
          -D CMAKE_BUILD_TYPE=Release -D GMX_SIMD=AVX_512 \
          -D GMX_BUILD_OWN_FFTW=ON -D GMX_GPU=ON -D GMX_MPI=ON -D GMX_OPENMP=ON \
          -D GMX_PREFER_STATIC_LIBS=ON /var/tmp/gromacs-2019.6 && \
    cmake --build /var/tmp/gromacs-2019.6/build --target all -- -j$(nproc) && \
    cmake --build /var/tmp/gromacs-2019.6/build --target install -- -j$(nproc) && \
    rm -rf /var/tmp/gromacs-2019.6 /var/tmp/gromacs-2019.6.tar.gz
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM sjtuhpc/hpc-base-container:gcc-8.cuda-10.2.ompi-4.0

# Gromacs version 2020
COPY --from=build /opt/gromacs /opt/gromacs
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH
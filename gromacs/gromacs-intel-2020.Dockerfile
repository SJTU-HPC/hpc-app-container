#===========================#
# multi-stage: build
#===========================#
FROM chengshenggan/hpc-base-container:intel-2021 AS build

RUN yum install -y \
        epel-release && \
    yum install -y \
        cmake3 \
        make \
        wget && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    rm -rf /var/cache/yum/*

RUN yum install -y centos-release-scl && \
    yum install -y \
        devtoolset-8-gcc \
        devtoolset-8-gcc-c++ && \
    rm -rf /var/cache/yum/*

# Gromacs version 2020
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://ftp.gromacs.org/pub/gromacs/gromacs-2020.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/gromacs-2020.tar.gz -C /var/tmp -z && \
    mkdir -p /var/tmp/gromacs-2020/build && cd /var/tmp/gromacs-2020/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gromacs -D CMAKE_BUILD_TYPE=Release \
          -D GMX_MPI=ON -D GMX_OPENMP=ON \
          -D CMAKE_C_COMPILER=mpiicc -D CMAKE_CXX_COMPILER=mpiicpc \
          -D GMX_GPLUSPLUS_PATH=/opt/rh/devtoolset-8/root/usr/bin/g++ \
          -D GMX_SIMD=AVX_512 -D GMX_FFT_LIBRARY=mkl \
          -D GMX_PREFER_STATIC_LIBS=ON /var/tmp/gromacs-2020 && \
    cmake --build /var/tmp/gromacs-2020/build --target all -- -j$(nproc) && \
    cmake --build /var/tmp/gromacs-2020/build --target install -- -j$(nproc) && \
    rm -rf /var/tmp/gromacs-2020 /var/tmp/gromacs-2020.tar.gz
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH


#===========================#
# multi-stage: install
#===========================#

FROM chengshenggan/hpc-base-container:intel-2021

# Gromacs version 2020
COPY --from=build /opt/gromacs /opt/gromacs
ENV LD_LIBRARY_PATH=/opt/gromacs/lib64:$LD_LIBRARY_PATH \
    PATH=/opt/gromacs/bin:$PATH
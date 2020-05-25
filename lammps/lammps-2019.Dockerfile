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

# LAMMPS version patch_19Sep2019 for CUDA compute capability sm70
RUN yum install -y \
        bc \
        hwloc-devel \
        make \
        tar \
        wget \
        which && \
    rm -rf /var/cache/yum/*

RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/lammps/lammps/archive/stable_7Aug2019.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/patch_19Sep2019.tar.gz -C /var/tmp -z && \
    cd /var/tmp/lammps-patch_19Sep2019/cmake && \
    sed -i 's/^cuda_args=""/cuda_args="--cudart shared"/g' /var/tmp/lammps-patch_19Sep2019/lib/kokkos/bin/nvcc_wrapper && \
    mkdir -p /var/tmp/lammps-patch_19Sep2019/build-Volta70 && cd /var/tmp/lammps-patch_19Sep2019/build-Volta70 && cmake -DCMAKE_INSTALL_PREFIX=/opt/lammps-sm70 -D BUILD_SHARED_LIBS=ON -D CUDA_USE_STATIC_CUDA_RUNTIME=OFF -D KOKKOS_ARCH=Volta70 -D CMAKE_BUILD_TYPE=Release -D MPI_C_COMPILER=mpicc -D BUILD_MPI=yes -D PKG_MPIIO=on -D BUILD_OMP=yes -D BUILD_LIB=no -D CMAKE_CXX_COMPILER=/var/tmp/lammps-patch_19Sep2019/lib/kokkos/bin/nvcc_wrapper -D PKG_USER-REAXC=yes -D PKG_KSPACE=yes -D PKG_MOLECULE=yes -D PKG_REPLICA=yes -D PKG_RIGID=yes -D PKG_MISC=yes -D PKG_MANYBODY=yes -D PKG_ASPHERE=yes -D PKG_GPU=no -D PKG_KOKKOS=yes -D KOKKOS_ENABLE_CUDA=yes -D KOKKOS_ENABLE_HWLOC=yes /var/tmp/lammps-patch_19Sep2019/cmake && \
    cmake --build /var/tmp/lammps-patch_19Sep2019/build-Volta70 --target all -- -j$(nproc) && \
    cmake --build /var/tmp/lammps-patch_19Sep2019/build-Volta70 --target install -- -j$(nproc) && \
    rm -rf /var/tmp/lammps-patch_19Sep2019/cmake /var/tmp/patch_19Sep2019.tar.gz /var/tmp/lammps-patch_19Sep2019/build-Volta70


#===========================#
# multi-stage: install
#===========================#

FROM chengshenggan/hpc-base-container:gcc-8.cuda-10.2.ompi-4.0

# LAMMPS version patch_19Sep2019 for CUDA compute capability sm70
RUN yum install -y \
        bc \
        hwloc-devel \
        which && \
    rm -rf /var/cache/yum/*
COPY --from=build /opt/lammps-sm70 /opt/lammps-sm70
ENV LD_LIBRARY_PATH=/opt/lammps-sm70/lib:$LD_LIBRARY_PATH \
    PATH=/opt/lammps-sm70/bin:$PATH

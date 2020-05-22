FROM chengshenggan/hpc-base-container:cuda-9.2.ompi-4.0 AS build

# RELION version 3.0.8
RUN yum install -y \
        make \
        cmake \
        wget \
        libtiff-devel \
        fltk-devel \
        fltk-fluid \
        fftw-devel && \
    rm -rf /var/cache/yum/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/3dem/relion/archive/3.0.8.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/3.0.8.tar.gz -C /var/tmp -z && \
    cd /var/tmp/relion-3.0.8/ && mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/relion/ -DCUDA=ON -DCudaTexture=ON -DCUDA_ARCH=70 .. && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/3.0.8.tar.gz /var/tmp/relion-3.0.8
ENV LD_LIBRARY_PATH=/opt/relion/lib:$LD_LIBRARY_PATH \
    PATH=/opt/relion/bin:$PATH


FROM chengshenggan/hpc-base-container:cuda-9.2.ompi-4.0
RUN yum install -y \
        which \
        libtiff-devel \
        fltk-devel \
        fltk-fluid \
        fftw-devel && \
    rm -rf /var/cache/yum/*

# RELION version 3.0.8
COPY --from=build /opt/relion /opt/relion
ENV LD_LIBRARY_PATH=/opt/relion/lib:$LD_LIBRARY_PATH \
    PATH=/opt/relion/bin:$PATH

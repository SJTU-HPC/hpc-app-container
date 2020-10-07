#===========================#
# multi-stage: build
#===========================#
FROM chengshenggan/hpc-base-container:intel-2021 AS build

RUN yum install -y \
        make \
        wget && \
    rm -rf /var/cache/yum/*

# Quantum ESPRESSO v6.6
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/QEF/q-e/archive/qe-6.6.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/qe-6.6.tar.gz -C /var/tmp -z && \
    cd /var/tmp/q-e-qe-6.6 && \
    ./configure --prefix=/opt/espresso && \
    make -j$(nproc) all && make install
ENV LD_LIBRARY_PATH=/opt/espresso/lib:$LD_LIBRARY_PATH \
    PATH=/opt/espresso/bin:$PATH


#===========================#
# multi-stage: install
#===========================#
FROM chengshenggan/hpc-base-container:intel-2021

# Quantum ESPRESSO v6.6
COPY --from=build /opt/espresso /opt/espresso
ENV LD_LIBRARY_PATH=/opt/espresso/lib:$LD_LIBRARY_PATH \
    PATH=/opt/espresso/bin:$PATH
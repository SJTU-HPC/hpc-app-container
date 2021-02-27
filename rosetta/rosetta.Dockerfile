FROM sjtuhpc/hpc-base-container:gcc-8.ompi-4.0

ARG ROSETTA_PASSWORD=XXXXX

LABEL Description="Rosetta docker" Version="3.12"

ENV ROSETTA /rosetta_src_2020.08.61146_bundle
ENV ROSETTA3_DB $ROSETTA/main/database
ENV ROSETTA_BIN $ROSETTA/main/source/bin
ENV PATH $PATH:$ROSETTA_BIN
ENV LD_LIBRARY_PATH $ROSETTA/main/source/bin:$LD_LIBRARY_PATH

RUN yum install -y boost-devel \
    boost \
    boost-doc 

RUN wget -q https://www.rosettacommons.org/downloads/academic/3.12/rosetta_src_3.12_bundle.tgz --password=${ROSETTA_PASSWORD} --user=Academic_User && \
    tar zxvf rosetta_src_* && \
    cd $ROSETTA/main/source/ && \
    ./scons.py mode=release bin extras=mpi && \
    cd / && rm -rf rosetta_src_3.12_bundle.tgz


FROM ubuntu:18.04 as builder

RUN apt-get update && \
    apt-get install -y locales jq vim wget curl gawk \
    cmake g++ g++-multilib make python python-dev python-pip

# Install basic dev tools
RUN pip install --upgrade pip
RUN pip install h5py keras numpy pillow scipy tensorflow-cpu subprocess32

# Set up environment variables
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \ 
	CXX=g++


WORKDIR /workspace/

#################################
# Download and Install Delfi IPC2018 version
#################################
ENV DL_URL=https:/bitbucket.org/ipc2018-classical/team23/get/ipc-2018-seq-opt.tar.gz
RUN curl -SL $DL_URL | tar -xz \
	&& mv ipc2018-classical-team23* delfi \
	&& cd delfi \
    && sed -i 's/-Werror//g' src/cmake_modules/FastDownwardMacros.cmake  \
	&& python ./build.py release64 \
    && cd symba \
    && sed -i 's/-Werror//g' src/search/Makefile \
    && ./build 


###############################################################################
## Second stage: the image to run the planners
## 
## This is the image that will be distributed, we will simply copy here
## the files that we fetched and compiled in the previous image and that 
## are strictly necessary to run the planners.
## Also, installing nodejs here.
###############################################################################

FROM ubuntu:18.04

# Install any package needed to *run* the planner
# RUN apt-get update && apt-get install --no-install-recommends -y \
#     python python-setuptools python-pip \
#     && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y locales curl gawk \
    # cmake g++ g++-multilib make \
    python python-dev python-pip \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \ 
	CXX=g++ 



# Install basic dev tools
RUN pip install --upgrade pip
RUN pip install keras==2.3.0 
RUN pip install h5py==2.10.0
RUN pip install numpy==1.16.6
RUN pip install scipy==1.2.3
RUN pip install pillow==6.2.2
RUN pip install setuptools==41.0.0
RUN pip install tensorflow-cpu==2.1.0

RUN pip install subprocess32

## Copying Delfi planner essential files
WORKDIR /workspace/delfi/

COPY --from=builder /workspace/delfi/dl_model ./dl_model
COPY --from=builder /workspace/delfi/plan-ipc.py .
COPY --from=builder /workspace/delfi/fast-downward.py .
COPY --from=builder /workspace/delfi/builds/release64/bin/ ./builds/release64/bin/
COPY --from=builder /workspace/delfi/driver ./driver
COPY --from=builder /workspace/delfi/create-image-from-graph.py .
COPY --from=builder /workspace/delfi/timers.py .
COPY --from=builder /workspace/delfi/symba/src/preprocess/preprocess ./symba/src/preprocess/preprocess
COPY --from=builder /workspace/delfi/symba/src/search/downward ./symba/src/search/downward
COPY --from=builder /workspace/delfi/symba/src/search/downward-1 ./symba/src/search/downward-1
COPY --from=builder /workspace/delfi/symba/src/search/downward-2 ./symba/src/search/downward-2
COPY --from=builder /workspace/delfi/symba/src/search/downward-4 ./symba/src/search/downward-4
COPY --from=builder /workspace/delfi/symba/src/search/dispatch ./symba/src/search/dispatch
COPY --from=builder /workspace/delfi/symba/src/search/unitcost ./symba/src/search/unitcost
COPY --from=builder /workspace/delfi/symba/src/translate ./symba/src/translate
COPY --from=builder /workspace/delfi/symba.py .
COPY --from=builder /workspace/delfi/symba/src/plan ./symba/src/plan
COPY --from=builder /workspace/delfi/symba/src/plan-ipc ./symba/src/plan-ipc
## Modifying /workspace/delfi/plan-ipc.py to point to a correct location of abstract_structure_module
RUN sed -i 's#src#builds/release64/bin#g' /workspace/delfi/plan-ipc.py


WORKDIR /work

ENTRYPOINT ["/usr/bin/python", "/workspace/delfi/plan-ipc.py", "--image-from-lifted-task"]






# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

# Based on Matlab Docker Template by Mathworks 
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/Dockerfile

# To specify which MATLAB release to install in the container, edit the value of the MATLAB_RELEASE argument.
# Use lower case to specify the release, for example: ARG MATLAB_RELEASE=r2021b
ARG MATLAB_RELEASE=r2024b

# When you start the build stage, this Dockerfile by default uses the Ubuntu-based matlab-deps image.
# To check the available matlab-deps images, see: https://hub.docker.com/r/mathworks/matlab-deps
FROM mathworks/matlab-deps:${MATLAB_RELEASE}

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE

# Install mpm dependencies & tini
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    tzdata \
    wget \
    unzip \
    ca-certificates \
    tini \
    && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && echo Etc/UTC > /etc/timezone \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards.
# If mpm fails to install successfully then output the logfile to the terminal, otherwise cleanup.
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \ 
    && chmod +x mpm \
    && ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=/opt/matlab \
    --products MATLAB \
    --product 5G_Toolbox \
    --product Communications_Toolbox \
    --product DSP_System_Toolbox \
    --product LTE_Toolbox \
    --product Signal_Processing_Toolbox \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log \
    && ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab \
    && mv /opt/matlab/sys/os/glnxa64/libstdc++.so.6 /opt/matlab/sys/os/glnxa64/libstdc++.so.6.bak \
    && mv /opt/matlab/sys/os/glnxa64/libquadmath.so.0 /opt/matlab/sys/os/glnxa64/libquadmath.so.0.bak

ARG MATLAB_USER
# Add "${MATLAB_USER}" user and grant sudo permission.
RUN adduser --shell /bin/bash --disabled-password --gecos "" ${MATLAB_USER} \
    && echo "${MATLAB_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MATLAB_USER} \
    && chmod 0440 /etc/sudoers.d/${MATLAB_USER}

# ${MATLAB_USER} dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    iproute2 ufw libfftw3-dev\
    clang-format cmake ninja-build gcc g++ git rsync libyaml-cpp-dev && \
    apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* 

USER ${MATLAB_USER}
WORKDIR /home/${MATLAB_USER}

# Use CUDA 11.7 base image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget cmake build-essential libgl1-mesa-glx libsm6 libxext6 \
    libxrender-dev libxcb-xinerama0 libglib2.0-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

WORKDIR /app

# Clone the IgGM repository
RUN git clone https://github.com/TencentAI4S/IgGM.git .

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Update the base environment with the repo's dependencies
RUN conda env update -n base -f environment.yaml

# Install PyG and PyRosetta
RUN pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
    -f https://data.pyg.org/whl/torch-2.0.1+cu117.html

RUN pip install https://west.rosettacommons.org/pyrosetta/release/release/PyRosetta4.Release.python310.ubuntu.wheel/pyrosetta-2025.37+release.df75a9c48e-cp310-cp310-linux_x86_64.whl

# Setup directories
RUN mkdir -p /app/checkpoints /app/outputs /app/hcp1_data

ENV PYTHONUNBUFFERED=1

# RunPod Interactive Mode
CMD ["/bin/bash", "-c", "sleep infinity"]

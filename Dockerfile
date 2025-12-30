# Use CUDA 11.7 base image (Matching the PyG wheels requirement)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install system dependencies (Git for cloning, plus PyRosetta/OpenMM deps)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    cmake \
    build-essential \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libxcb-xinerama0 \
    libglib2.0-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Set working directory
WORKDIR /app

# CLONE the IgGM repository during build
RUN git clone https://github.com/TencentAI4S/IgGM.git .

# Create the Conda environment from the cloned environment.yaml
# We create it as the 'base' to make it easier to use in RunPod
RUN conda env update -n base -f environment.yaml

# Install PyG wheels and PyRosetta into the base environment
# Note: Using 'pip' here works as it's now part of the conda base env
RUN pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
    -f https://data.pyg.org/whl/torch-2.0.1+cu117.html

# Install PyRosetta (The version specified in IgGM README)
RUN pip install https://west.rosettacommons.org/pyrosetta/release/release/PyRosetta4.Release.python310.ubuntu.wheel/pyrosetta-2025.37+release.df75a9c48e-cp310-cp310-linux_x86_64.whl

# Pre-create directories for your data and model weights
RUN mkdir -p /app/checkpoints /app/outputs /app/hcp1_data

# Ensure python logs are sent straight to terminal
ENV PYTHONUNBUFFERED=1

# Keep the container alive indefinitely so you can enter it via RunPod terminal
CMD ["/bin/bash", "-c", "sleep infinity"]

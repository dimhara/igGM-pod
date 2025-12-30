# Use official PyTorch image (Torch 2.0.1 + CUDA 11.7 + Conda included)
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Install uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1 

# Install system dependencies for PyRosetta, OpenMM, and general tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget cmake build-essential libgl1-mesa-glx libsm6 libxext6 \
    libxrender-dev libxcb-xinerama0 libglib2.0-0 ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Clone IgGM
RUN git clone https://github.com/TencentAI4S/IgGM.git .

# 2. Install OpenMM and Pdbfixer via CONDA
# These packages are problematic on PyPI but standard on conda-forge
RUN conda install -y -c conda-forge openmm pdbfixer && \
    conda clean -afy

# 3. Install remaining dependencies via UV
# We use the PyRosetta link from your successful log and the PyG CUDA wheels.
RUN uv pip install --no-cache \
    pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
    -f https://data.pyg.org/whl/torch-2.0.1+cu117.html && \
    uv pip install --no-cache \
    https://west.rosettacommons.org/pyrosetta/release/release/PyRosetta4.Release.python310.ubuntu.wheel/pyrosetta-2025.51+release.612b6ef9e9-cp310-cp310-linux_x86_64.whl && \
    uv pip install --no-cache \
    biopython==1.79 pandas scipy matplotlib seaborn tqdm pyyaml \
    requests ml-collections abnumber logomaker biopandas

# 4. Setup project directories
RUN mkdir -p /app/checkpoints /app/outputs /app/hcp1_data

# RunPod Interactive Mode
CMD ["/bin/bash", "-c", "sleep infinity"]

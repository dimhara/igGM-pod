# Use official PyTorch image (Torch 2.0.1 + CUDA 11.7 + Conda included)
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Install uv binary for high-speed installation
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1 

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget cmake build-essential libgl1-mesa-glx libsm6 libxext6 \
    libxrender-dev libxcb-xinerama0 libglib2.0-0 ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Clone IgGM
RUN git clone https://github.com/TencentAI4S/IgGM.git .

# 2. Install OpenMM and Pdbfixer via CONDA
RUN conda install -y -c conda-forge openmm pdbfixer && \
    conda clean -afy

# 3. Install AI Stack, PyRosetta, and MISSING UTILS (termcolor, einops, dm-tree)
RUN uv pip install --no-cache \
    pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
    -f https://data.pyg.org/whl/torch-2.0.1+cu117.html && \
    uv pip install --no-cache \
    https://west.rosettacommons.org/pyrosetta/release/release/PyRosetta4.Release.python310.ubuntu.wheel/pyrosetta-2025.51+release.612b6ef9e9-cp310-cp310-linux_x86_64.whl && \
    uv pip install --no-cache \
    biopython==1.79 pandas scipy matplotlib seaborn tqdm pyyaml \
    requests ml-collections abnumber logomaker biopandas \
    termcolor einops dm-tree

# 4. DOWNLOAD WEIGHTS (The 2GB Risk)
# Pre-creating the directory and downloading files into the final location
RUN mkdir -p /app/checkpoints && \
    wget -q https://zenodo.org/records/16909543/files/esm_ppi_650m_ab.pth?download=1 -O /app/checkpoints/esm_ppi_650m_ab.pth && \
    wget -q https://zenodo.org/records/16909543/files/antibody_design_trunk.pth?download=1 -O /app/checkpoints/antibody_design_trunk.pth && \
    wget -q https://zenodo.org/records/16909543/files/igso3_buffer.pth?download=1 -O /app/checkpoints/igso3_buffer.pth

# 5. Setup project paths and env
RUN mkdir -p /app/outputs /app/hcp1_data
ENV PYTHONPATH=$PYTHONPATH:/app

# RunPod Interactive Mode
CMD ["/bin/bash", "-c", "sleep infinity"]

# Use CUDA 11.7 base image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    cmake \
    build-essential \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -u -p /opt/conda && \
    rm ~/miniconda.sh

# Set working directory
WORKDIR /app

# Copy the environment.yaml from the repo
COPY environment.yaml .

# Create the Conda environment
RUN conda env create -n IgGM -f environment.yaml

# Initialize shell for conda
SHELL ["conda", "run", "-n", "IgGM", "/bin/bash", "-c"]

# Install specific PyG versions as required by README
RUN pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.0.1+cu117.html

# (Optional) Pre-create checkpoints directory to store weights
RUN mkdir -p /app/checkpoints

# Copy the rest of the application code
COPY . .

# Copy and set permissions for the start script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
#ENTRYPOINT ["/app/entrypoint.sh"]
# TEST FIRST --  Keep the container running
CMD ["sleep", "infinity"]

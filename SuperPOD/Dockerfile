# Use an official Python runtime as a parent image
FROM nvcr.io/nvidia/pytorch:24.08-py3 

# Install packages
RUN pip install --upgrade pip setuptools wheel && \
    apt-get update && \
    apt-get install -y libgl1 openssh-server python3-venv netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

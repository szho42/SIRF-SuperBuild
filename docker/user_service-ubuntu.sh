#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

# SIRF-Exercises
git clone https://github.com/CCPPETMR/SIRF-Exercises --recursive -b master
# for downloading SIRF-Exercises data
which unzip || apt-get install -yqq unzip && apt-get clean

# link /devel share
[ -e ./devel ] || ln -s /devel

conda install -c conda-forge -y ipykernel ipywidgets && conda clean -y --all|| \
  pip install --no-cache-dir ipykernel ipywidgets
pip install --no-cache-dir keras tensorboard tensorflow-gpu
python -m ipykernel install --name sirf --display-name "Python (sirf)"

if [ -f requirements-hub.txt ]; then
  conda create -n hub -c conda-forge -y python=3
  conda activate hub
  conda install -c conda-forge -y --file requirements-hub.txt
  conda clean -y --all
  #pip3 install --no-cache-dir -r requirements-hub.txt

  jupyter labextension install @jupyter-widgets/jupyterlab-manager
  jupyter contrib nbextension install --sys-prefix
fi

#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

# SIRF-Exercises
git clone https://github.com/CCPPETMR/SIRF-Exercises --recursive -b master $INSTALL_DIR/SIRF-Exercises

if [ -f requirements-service.txt ]; then
  conda install -c conda-forge -y --file requirements-service.txt || \
  pip install -U -r requirements-service.txt
fi
python -m ipykernel install --name sirf --display-name "Python (sirf)"

if [ -f requirements-hub.txt ]; then
  ( set -e
    conda create -n hub -c conda-forge -y --file requirements-hub.txt python=3
    conda activate hub
  ) || \
  pip3 install -U -r requirements-hub.txt

  jupyter labextension install @jupyter-widgets/jupyterlab-manager
  jupyter contrib nbextension install --sys-prefix
fi

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

# jupyter labextension install @jupyter-widgets/jupyterlab-manager

python -m ipykernel install --name sirf --display-name "Python (sirf)"
jupyter contrib nbextension install --sys-prefix

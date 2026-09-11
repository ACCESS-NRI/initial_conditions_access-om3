#!/bin/bash

set -e

module purge
module use /g/data/xp65/public/modules
module load conda/analysis3-26.08

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REGRIDDER_DIR="${SCRIPT_DIR}/ocean-ic/regridder"

# extension suffix: https://scikit-build.readthedocs.io/en/latest/cmake-modules/PythonExtensions.html#:~:text=PY_FORWARD_DECL_MODULES_LIST%20is%20used.-,MODULE_SUFFIX%20%3CModuleSuffix%3E,all%20extensions%20not%20having%20a%20suffix%20explicitly%20specified%20using%20MODULE_SUFFIX%20parameter.,-python_standalone_executable
EXT_SUFFIX=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")
PYTHRAN_SO="${SCRIPT_DIR}/apply_weights${EXT_SUFFIX}"
echo "Expected Pythran extension: ${PYTHRAN_SO}"

REGRIDDER_SO="${REGRIDDER_DIR}/apply_weights${EXT_SUFFIX}"

if [[ -f "${PYTHRAN_SO}" ]]; then
    echo "Pythran extension already exists. Skipping build."

    ln -sfn "${PYTHRAN_SO}" "${REGRIDDER_SO}"
    PYTHONPATH="${SCRIPT_DIR}/ocean-ic${PYTHONPATH:+:$PYTHONPATH}" \
    python3 -c 'import regridder.apply_weights as raw; print("Loaded:", raw.__file__)'
    exit 0
else
    echo "No extension for current Python version"
    rm -f "${SCRIPT_DIR}"/apply_weights*.so
    rm -f "${REGRIDDER_DIR}"/apply_weights*.so
fi

# create a temporary build env
PYTHRAN_VENV="$(mktemp -d "${TMPDIR:-/tmp}/pythran_build_XXXXXX")"

echo "Building Pythran extension in temporary environment: ${PYTHRAN_VENV}"
python3 -m venv --system-site-packages "${PYTHRAN_VENV}"

# install Pythran
echo "Installing Pythran in temporary environment..."
$PYTHRAN_VENV/bin/python3 -m pip install "pythran==0.19.0"

# Build extension
echo "Building Pythran extension..."
# https://pythran.readthedocs.io/en/latest/CLI.html#:~:text=If%20you%20want%20to%20specify%20the%20path%20of%20generated%20file%3A
${PYTHRAN_VENV}/bin/pythran "${REGRIDDER_DIR}/apply_weights.py" -o "${PYTHRAN_SO}"

# Verify that the extension was built
echo "Verifying Pythran extension..."
if [[ ! -f "${PYTHRAN_SO}" ]]; then
    echo "Error: Pythran extension was not built successfully."
    exit 1
fi

echo "Pythran extension built:"

# Make it visible to regridder
ln -sfn "${PYTHRAN_SO}" "${REGRIDDER_SO}"

PYTHONPATH="${SCRIPT_DIR}/ocean-ic${PYTHONPATH:+:${PYTHONPATH}}" \
    python3 -c 'import regridder.apply_weights as raw; print("Loaded:", raw.__file__)'

# Remove the temporary build env
rm -rf "$PYTHRAN_VENV"

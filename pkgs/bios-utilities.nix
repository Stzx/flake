{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "bios-utilities";
  version = "25.7.1";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "biosutilities";
    hash = "sha256-1+zOHPjJz/XtORy+5MzHCoauX5IT5AaBUSG+QX/yzY0=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    dissect-util
    pefile
  ];

  pythonImportsCheck = [
    "biosutilities"
  ];

  meta = {
    description = "Collection of various BIOS/UEFI-related utilities which aid in research and/or modding purposes";
    homepage = "https://github.com/platomav/BIOSUtilities";
    changelog = "https://github.com/platomav/BIOSUtilities/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.bsd2Patent;
    mainProgram = "bios-utilities";
  };
}

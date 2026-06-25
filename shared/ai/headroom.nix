# Headroom — context-compression layer for LLM agents (https://github.com/headroomlabs-ai/headroom).
#
# Installed from the upstream prebuilt manylinux wheel rather than built from
# source. The project is a maturin/pyo3 mix whose Rust core (headroom-core)
# hard-depends on fastembed + magika → ort (ONNX Runtime) + image, which require
# rustc >= 1.88 (this nixpkgs ships 1.86) and native ONNX-Runtime linking. The
# published abi3 wheel already bundles the compiled `headroom._core` extension,
# so autoPatchelf for NixOS is all that is needed.
#
# Scope is Core + MCP — the compression engine, `headroom wrap <agent>`, and the
# `headroom mcp` server. The wheel's _core carries every Rust feature, but the
# Python deps below cover only Core + MCP; proxy / ML / image / voice extras are
# intentionally omitted (heavier closure; the proxy extra also needs openai>=2.14
# and sqlite-vec, neither available in this nixpkgs).
{
  lib,
  fetchurl,
  autoPatchelfHook,
  stdenv,
  zlib,
  ast-grep,
  buildPythonApplication,
  tiktoken,
  pydantic,
  litellm,
  click,
  rich,
  opentelemetry-api,
  mcp,
  httpx,
}:
buildPythonApplication rec {
  pname = "headroom-ai";
  version = "0.27.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/8f/70/2e287f4f4bc8306c8c51bb40e753cfdfa05c568d026be633c78d9f4f2995/headroom_ai-${version}-cp310-abi3-manylinux_2_28_x86_64.whl";
    hash = "sha256-ZA5npBdDJlN2WCqSaRoZKowkSO8LIWeg4UoqRYrb4t0=";
  };

  # Patch the bundled `headroom/_core*.so` (and any vendored ONNX-Runtime libs)
  # to NixOS library paths.
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib zlib];

  # nixpkgs litellm (1.69) is older than the wheel's >=1.86.2 floor, but litellm
  # is lazily imported and ImportError-guarded — core compression and the
  # Anthropic proxy path never touch it. Relax the bound rather than override.
  pythonRelaxDeps = ["litellm"];

  # `ast-grep-cli` is a PyPI distribution that only ships the ast-grep/sg
  # binaries (headroom shells out to them); it is not a Python module. Drop the
  # metadata dependency and put the native ast-grep on PATH instead.
  pythonRemoveDeps = ["ast-grep-cli"];

  dependencies = [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    # [mcp] extra — enables `headroom mcp`.
    mcp
    httpx
  ];

  makeWrapperArgs = ["--prefix PATH : ${lib.makeBinPath [ast-grep]}"];

  pythonImportsCheck = ["headroom"];

  meta = {
    description = "Context-compression layer that cuts LLM token usage (Core + MCP build)";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}

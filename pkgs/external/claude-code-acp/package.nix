{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "claude-agent-acp";
  version = "0.29.2";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    tag = "v${version}";
    hash = "sha256-egYGwkN8iexw42EIhUgKb+QuAKfH4lKts0lftzfHAiY=";
  };

  npmDepsHash = "sha256-sUB/S3EycM3FGibAaZMA1T7tCyDu2XfkSg86qcABmYk=";

  meta = {
    description = "Use Claude Agent SDK from any ACP client";
    homepage = "https://github.com/agentclientprotocol/claude-agent-acp";
    changelog = "https://github.com/agentclientprotocol/claude-agent-acp/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "claude-agent-acp";
    platforms = lib.platforms.all;
  };
}

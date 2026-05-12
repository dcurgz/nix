{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  name = "twitch-chat-cli";
  src = fetchFromGitHub {
    owner = "martinbjeldbak";
    repo = "twitch-chat-cli";
    rev = "0861080";
    hash = "sha256-pTOR5jAlGyRFUGIdn4GhjzdTRuzP1fEOPyWI+yLSIu0=";
  };
  vendorHash = "sha256-qADDtAcTl9K8aDYfdbmGxo5TLBYptHJz9Ntk9/H4c/s=";
}

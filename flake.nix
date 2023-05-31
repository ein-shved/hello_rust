{
  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #pkgs-cross = import pkgs.path {
    pkgs-cross = import <nixpkgs> {
      crossSystem = pkgs.lib.systems.examples.armhf-embedded // {
        rustc.config = "thumbv7em-none-eabi";
      };
    };
  in
   {
    hello = with pkgs-cross;rustPlatform.buildRustPackage {
      pname = "hello";
      version = "0.1.0";
      cargoLock = {
        lockFile = ./Cargo.lock;
      };
      src = ./.;
    };
    np = nixpkgs;
  };
}

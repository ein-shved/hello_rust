{
  description = "The rust hello project for stm32";
  inputs = {
    stm32.url = github:ein-shved/nix-stm32;
  };
  outputs = { self, stm32, nixpkgs } :
  let
    generic = stm32.mkRustFirmware {
      pname = "hello_rust";
      version = "0.1.0";
      mcu = stm32.mcus.stm32f103;
      src = ./generic/.;
      cargoLock = {
        lockFile = ./generic/Cargo.lock;
      };
    };
  in
  stm32.mergeFirmwares {
    inherit generic;
    default = generic;
  };
}

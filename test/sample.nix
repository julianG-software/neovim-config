{ pkgs, lib, config, ... }:

let
  greeting = name: "Hello, ${name}!";

  # statix: use pkgs.lib instead of importing lib separately
  numbers = builtins.genList (x: x * 2) 5;

  # deadnix: unused binding
  unusedVar = "this is never used";

  mySet = {
    foo = "bar";
    nested = {
      value = 42;
      enabled = true;
    };
  };

  # statix: bool comparison anti-pattern (use value directly)
  isEnabled = if mySet.nested.enabled == true then true else false;

  conditionalPkg = if pkgs.stdenv.isLinux then pkgs.hello else pkgs.cowsay;

in
{
  options.myModule = {
    enable = lib.mkEnableOption "my test module";

    message = lib.mkOption {
      type = lib.types.str;
      default = "default message";
      description = "A message to display.";
    };
  };

  config = lib.mkIf config.myModule.enable {
    environment.systemPackages = with pkgs; [
      ripgrep
      fd
      conditionalPkg
    ];

    systemd.services.my-service = {
      description = "My test service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hello}/bin/hello";
        Restart = "on-failure";
      };
    };
  };
}

{...}: let
  hostname = "macbook-air-m2";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  networking.localHostName = hostname;
}

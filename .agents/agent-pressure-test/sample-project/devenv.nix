{ pkgs, config, ... }:

{
  languages.go.enable = true;

  # Local Postgres and Redis. Start them with `devenv up`, then `make migrate`.
  # The password is a local dev-only value; it must match DATABASE_URL in .env.
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = 5432;
    initialDatabases = [
      {
        name = "ledger";
        user = "ledger";
        pass = "ledger_dev_only";
      }
    ];
  };
  services.redis.enable = true;

  packages = [ config.services.postgres.package ];

  dotenv.enable = true;

  enterShell = ''
    go mod download
  '';
}

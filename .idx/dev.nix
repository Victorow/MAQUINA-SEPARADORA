# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk17
    pkgs.unzip
    pkgs.mariadb   # Adicionado para o servidor MariaDB
    pkgs.nodejs_20 # Adicionado para Node.js (para Node-RED)
    # Se precisar do Dart SDK explicitamente (além do que o Flutter extension provê),
    # você poderia adicionar pkgs.dart aqui também.
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        # Exemplo: Se você quisesse rodar um script na criação do workspace
        # script = ''
        #   echo "Workspace criado pela primeira vez!"
        # '';
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
      # onStart = {
      #   # Exemplo: Iniciar o servidor MariaDB automaticamente (requer configuração mais detalhada do serviço)
      #   # script = ''
      #   #  echo "Iniciando MariaDB no onStart..."
      #   #  # Comando para iniciar MariaDB (pode ser complexo aqui, melhor manual ou via systemd se suportado)
      #   # '';
      # };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"]; # Você pode precisar de `pkgs.android-tools` se for usar emulador Android diretamente no IDX
          manager = "flutter";
        };
      };
    };
  };
  # Adicionando um comentário para tentar acionar a reconstrução do ambiente - 30 de Maio de 2025
}
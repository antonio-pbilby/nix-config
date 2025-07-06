{
  description = "Example Go development environment for Zero to Nix";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            zsh
            go
            fnm
            starship
            fzf
            kubectl
            kustomize
          ];

          shellHook = ''
            grep -qxF 'eval "$(starship init zsh)"' $HOME/.zshrc || echo 'eval "$(starship init zsh)"' >> $HOME/.zshrc
            grep -qxF 'eval "$(fnm env --use-on-cd --shell zsh)"' $HOME/.zshrc || echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> $HOME/.zshrc

            exec "${pkgs.zsh}/bin/zsh"
            echo $HOME
            cd $HOME
          '';
        };
      });
    };
}

#./Home-Manager/Configs/bash.nix
{pkgs, lib, config, ...}:
{
  programs.bash = {
    enable = true;

    sessionVariables = {
      EDITOR = "nano";
      PATH = "$HOME/bin:$PATH";
    };

    initExtra = ''
      # Vimjoyer
      #PS1='$(if [ $EUID -eq 0 ]; then echo "\[\e[1;31m\]\w\n[root@Milvus-milvus]\$ \[\e[0m\]"; else echo "\[\e[38;2;177;98;134m\]\w\n\[\e[38;2;204;36;29m\][\[\e[38;2;215;153;33m\]\u\[\e[38;2;152;151;26m\]@\[\e[38;2;69;133;136m\]\h\[\e[38;2;204;52;29m\]]\[\e[39m\]\$ "; fi)'

      # ChallengerDeep/Vimjoyer
      PS1='$(if [ $EUID -eq 0 ]; then echo "\[\e[1;31m\]\w\n[root@Milvus-milvus]\$ \[\e[0m\]"; else echo "\[\e[38;2;199;146;234m\]\w\n\[\e[38;2;255;84;84m\][\[\e[38;2;255;203;107m\]\u\[\e[38;2;195;232;141m\]@\[\e[38;2;137;221;255m\]\h\[\e[38;2;255;84;84m\]]\[\e[0m\]\$ "; fi)'

      bind "set completion-ignore-case on"

      rb() {
        if sudo nixos-rebuild switch --flake ~/NixOS#Milvus-milvus; then
          echo -e "\n\e[38;2;0;200;50mI know kung fu.\n"
        else
          echo -e "\n\e[38;2;204;52;29mStop trying to hit me and hit me!\n"
        fi
      }
    '';

    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      ff = "fastfetch --logo none";
      bcf = "codium ~/.bashrc";
      ga = "git add";
      gc = "git commit -m";
      gaa = "git add ./";
      agr = ''cd ~/NixOS && git add ./ && git commit -m "AUTOMATED REBUILD" && rb && cd ~/'';
      cu = ''sudo nix-collect-garbage -d && echo -e "\n\e[38;2;0;200;50mFree your mind.\n"'';
      bc = "cat ~/.bashrc";
      gp = "git push -u origin main";
      upgrade = ''gin && nix flake update && gaa && gc "AUTOMATED REBUILD: NIX FLAKE UPDATE" && rb'';
      su = "sudo bash --rcfile ~/.bashrc";
      cat = "bat";
      fzf = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      all = "gin && gaa && gc";
      pll="cd ~/Downloads/'Telegram Desktop' && ls | sed 's|^|../|' > 'tmp.m3u'";
      gin = "cd ~/NixOS";
      vps = "bash ~/vpn-switcher.sh";
      edky = "sops ~/NixOS/secrets/secrets.yaml";
      dlm = "scp -r john@192.168.122.94:~/Downloads/t ~/Downloads/";
      ns-c = "cd ~/Documents/Programming/Shells/C && nix-shell && codium ./";
      ns-cs = ''cd ~/Documents/Programming/Shells/CSharp && nix-shell --run "codium ./"'';
      ns-py = ''cd ~/Documents/Programming/Shells/Python312 && nix-shell --run "codium ./"'';
      ns-rs = ''cd ~/Documents/Programming/Shells/Rust && nix-shell --run "codium ./"'';
    };
  };
}

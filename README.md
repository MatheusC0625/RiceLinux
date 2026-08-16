# Dotfiles — Rice Hyprland (Gruvbox)

Desktop Linux com Hyprland no Debian 13 (Trixie) · Wayland · estetica Gruvbox.
Notebook ASUS Vivobook (Ryzen 5 7520U). GNOME permanece como sessao fallback no GDM.

== ATALHOS (SUPER = tecla Windows) ==

-- Aplicativos --
SUPER + Enter        Terminal (Kitty)
SUPER + R            Launcher de apps (Rofi)
SUPER + E            Gerenciador de arquivos (Nautilus)
SUPER + Q            Fechar janela ativa

-- Janelas e Workspaces --
SUPER + V            Alternar flutuante / encaixada
SUPER + F            Tela cheia
SUPER + [1-4]        Ir para workspace 1-4
SUPER + SHIFT + [1-4]   Mover janela para workspace 1-4
SUPER + arrastar esq.  Mover janela
SUPER + arrastar dir.  Redimensionar janela
SUPER + M            Sair do Hyprland

-- Screenshots --
Print                Tela inteira -> ~/Pictures/screenshots
SUPER + Print        Selecionar regiao -> salva
SUPER + SHIFT + S    Selecionar regiao -> copia pro clipboard

-- Midia --
Volume, mute, mic e brilho mapeados nas teclas F do notebook.

== COMANDOS DE MANUTENCAO ==

-- Recarregar componentes --
hyprctl reload
killall waybar; systemctl --user restart waybar.service
makoctl reload
systemctl --user restart hyprpaper.service

-- Trocar wallpaper --
1. coloque a imagem em ~/Pictures/wallpapers/
2. edite o caminho em ~/.config/hypr/hyprpaper.conf (path = ...)
3. systemctl --user restart hyprpaper.service

-- Tela de bloqueio --
hyprlock

-- Diagnostico --
hyprctl clients
hyprctl monitors
systemctl --user status hyprpaper.service
fc-list | grep -i nerd

== CONFIGURACAO VISUAL ==

Tema GTK: Adwaita-dark | Icones: Papirus-Dark (via nwg-look)
Fonte: JetBrainsMono Nerd Font
Wallpaper: ~/Pictures/wallpapers/anime-gruvbox.png

-- Paleta Gruvbox --
Fundo         #282828   Base escura
Fundo alt     #3c3836   Elementos elevados
Texto         #ebdbb2   Texto principal
Texto apagado #a89984   Texto secundario
Destaque      #d65d0e   Acento (laranja)

== ESTRUTURA ==

dotfiles/
  hypr/     hyprland.conf, hyprpaper.conf, hyprlock.conf, hypridle.conf
  waybar/   config.jsonc + style.css
  rofi/     config.rasi + gruvbox.rasi
  kitty/    kitty.conf
  mako/     config
  gtk/      settings.ini (GTK3/GTK4)
  README.md

== NOTAS IMPORTANTES (aprendizados) ==

- Hyprpaper usa sintaxe de BLOCO (wallpaper { monitor=...; path=... }), nao linha unica.
- Icones da Waybar: glifos via codigo Unicode (\uXXXX) p/ nao corromper ao colar no terminal.
- Hyprland 0.55+: sintaxe de windowrule mudou (hyprlang -> lua). float/size/move sao frageis;
  preferimos tiling + gaps para o layout dos terminais.
- cava/fastfetch abrem no workspace 1 via: exec-once = [workspace 1 silent] ...
- Spotify vai pro workspace 2 automaticamente.
- GNOME continua instalado - se algo quebrar, escolha GNOME no login (GDM).

== IDEIAS FUTURAS ==

[ ] Cursor personalizado (ex: Bibata)
[ ] Cava em cores Gruvbox
[ ] Cores das bordas do Hyprland
[ ] Neovim em Gruvbox
[ ] Organizar dotfiles com symlinks (GNU Stow)

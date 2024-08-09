{ config, pkgs, ... }:

{
  # Wofi install
  environment.systemPackages = with pkgs; [ wofi ];

  # Wofi configuration
  home.file.".config/wofi/config".text = ''
    width=500
    height=300
    location=center
    show=drun
    prompt=Search...
    filter_rate=100
    allow_markup=true
    no_actions=true
    halign=fill
    orientation=vertical
    content_halign=fill
    insensitive=true
    allow_images=true
    image_size=20
    gtk_dark=true
  '';

  # Wofi style
  home.file.".config/wofi/style.css".text = ''
    window {
      margin: 0px;
      border: 2px solid #414868;
      background-color: rgba(30, 30, 46, 0.9);
      border-radius: 15px;
    }

    #input {
      all: unset;
      min-height: 36px;
      padding: 4px 10px;
      margin: 4px;
      border: none;
      color: #c0caf5;
      font-weight: bold;
      background-color: #24283b;
      outline: none;
      border-radius: 15px;
      margin: 10px;
      margin-bottom: 2px;
    }

    #inner-box {
      margin: 4px;
      color: #c0caf5;
      font-weight: bold;
      background-color: rgba(30, 30, 46, 0.9);
    }

    #outer-box {
      margin: 0px;
      border: none;
      border-radius: 15px;
      background-color: rgba(30, 30, 46, 0.9);
    }

    #scroll {
      margin-top: 5px;
      border: none;
      border-radius: 15px;
      margin-bottom: 5px;
    }

    #text:selected {
      color: #1e1e2e;
      margin: 0px 0px;
      border: none;
      border-radius: 15px;
    }

    #entry {
      margin: 0px 0px;
      border: none;
      border-radius: 15px;
      background-color: transparent;
    }

    #entry:selected {
      margin: 0px 0px;
      border: none;
      border-radius: 15px;
      background-color: #7aa2f7;
    }
  '';
}

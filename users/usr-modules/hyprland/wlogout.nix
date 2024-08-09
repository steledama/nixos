{ config, pkgs, ... }:

let
  # Define the path to your custom icons
  iconPath = "${config.home.homeDirectory}/.config/hypr/wlogoutIcons";
in
{
  # Install wlogout
  home.packages = with pkgs; [
    wlogout
  ];

  # Ensure the icon directory exists
  home.file.".config/hypr/wlogoutIcons/.keep".text = "";

  # Copy custom icons to the correct location
  # You need to place your icons in the nix configuration directory
  # alongside this wlogout.nix file
  home.file = {
    "${iconPath}/lock.png".source = ./wlogoutIcons/lock.png;
    "${iconPath}/logout.png".source = ./wlogoutIcons/logout.png;
    "${iconPath}/suspend.png".source = ./wlogoutIcons/suspend.png;
    "${iconPath}/hibernate.png".source = ./wlogoutIcons/hibernate.png;
    "${iconPath}/shutdown.png".source = ./wlogoutIcons/shutdown.png;
    "${iconPath}/reboot.png".source = ./wlogoutIcons/reboot.png;
  };

  # Configuration for wlogout
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "swaylock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
    }
    {
        "label" : "logout",
        "action" : "loginctl terminate-user $USER",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
  '';

  # Style configuration for wlogout
  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
    }
    window {
        background-color: rgba(12, 12, 12, 0.9);
    }
    button {
        color: #FFFFFF;
        background-color: #1E1E1E;
        border-style: solid;
        border-width: 2px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
    }
    
    button:focus, button:active, button:hover {
        background-color: #3700B3;
        outline-style: none;
    }
    
    #lock {
        background-image: image(url("${iconPath}/lock.png"));
    }
    
    #logout {
        background-image: image(url("${iconPath}/logout.png"));
    }
    
    #suspend {
        background-image: image(url("${iconPath}/suspend.png"));
    }
    
    #hibernate {
        background-image: image(url("${iconPath}/hibernate.png"));
    }
    
    #shutdown {
        background-image: image(url("${iconPath}/shutdown.png"));
    }
    
    #reboot {
        background-image: image(url("${iconPath}/reboot.png"));
    }
  '';
}

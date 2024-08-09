{ config, pkgs, ... }:

let
  # Define paths for custom icons if you want to use them
  # Otherwise, wlogout will use its default icons
  iconPath = "/path/to/your/icons";
in
{
  # Install wlogout at system level
  environment.systemPackages = with pkgs; [
    wlogout
  ];

  # Create a system-wide configuration for wlogout
  environment.etc."wlogout/layout".text = ''
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

  # Create a system-wide style configuration for wlogout
  environment.etc."wlogout/style.css".text = ''
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
        background-image: image(url("${iconPath}/lock.png"), url("/usr/share/wlogout/icons/lock.png"));
    }
    
    #logout {
        background-image: image(url("${iconPath}/logout.png"), url("/usr/share/wlogout/icons/logout.png"));
    }
    
    #suspend {
        background-image: image(url("${iconPath}/suspend.png"), url("/usr/share/wlogout/icons/suspend.png"));
    }
    
    #hibernate {
        background-image: image(url("${iconPath}/hibernate.png"), url("/usr/share/wlogout/icons/hibernate.png"));
    }
    
    #shutdown {
        background-image: image(url("${iconPath}/shutdown.png"), url("/usr/share/wlogout/icons/shutdown.png"));
    }
    
    #reboot {
        background-image: image(url("${iconPath}/reboot.png"), url("/usr/share/wlogout/icons/reboot.png"));
    }
  '';
}

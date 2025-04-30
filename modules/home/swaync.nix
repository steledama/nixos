# modules/home/swaync-simplified.nix
# Simplified SwayNC notification center configuration for Wayland WMs
{ pkgs, ... }:

let
  colors = import ./colors.nix;
in
{
  # Install SwayNC and libnotify
  home.packages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];

  # Configuration files
  xdg.configFile = {
    # Main SwayNC configuration
    "swaync/config.json".text = builtins.toJSON {
      "$schema" = "/etc/xdg/swaync/configSchema.json";

      # Basic notification center options
      "positionX" = "right";
      "positionY" = "top";
      "layer" = "overlay";
      "cssPriority" = "application";
      "control-center-margin-top" = 10;
      "control-center-margin-bottom" = 10;
      "control-center-margin-right" = 10;
      "control-center-margin-left" = 10;
      "notification-icon-size" = 64;
      "notification-body-image-height" = 100;
      "notification-body-image-width" = 200;
      "timeout" = 10;
      "timeout-low" = 5;
      "timeout-critical" = 0;
      "fit-to-screen" = true;
      "control-center-width" = 400;
      "notification-window-width" = 400;
      "keyboard-shortcuts" = true;
      "image-visibility" = "when-available";
      "transition-time" = 200;
      "hide-on-clear" = true;
      "hide-on-action" = true;
      "script-fail-notify" = true;

      # Notification center widgets
      "widgets" = [
        "title"
        "dnd"
        "notifications"
        "buttons-grid"
      ];

      # Quick action buttons
      "widgets-config" = {
        "buttons-grid" = {
          "actions" = [
            {
              "label" = "Clear All";
              "command" = "swaync-client -C";
            }
            {
              "label" = "Settings";
              "command" = "gnome-control-center";
            }
          ];
        };

        "dnd" = {
          "text" = "Do Not Disturb";
        };
      };
    };

    # SwayNC style configuration
    "swaync/style.css".text = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
      }

      .control-center {
        background-color: ${colors.background};
        border-radius: 10px;
        border: 2px solid ${colors.blue};
        color: ${colors.foreground};
      }

      .notification-row {
        outline: none;
        margin: 10px;
        padding: 8px;
      }

      .notification {
        background-color: rgba(40, 42, 54, 0.7);
        border-radius: 8px;
        border: 1px solid ${colors.blue};
        margin: 6px;
        box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
      }

      .notification-content {
        padding: 6px;
        margin: 6px;
      }

      .title {
        font-weight: bold;
        color: ${colors.yellow};
        margin: 6px;
      }

      .body {
        color: ${colors.foreground};
      }

      .button-container {
        margin: 8px;
      }

      .button {
        background-color: ${colors.black};
        color: ${colors.foreground};
        border-radius: 5px;
        border: 1px solid ${colors.blue};
        padding: 6px 10px;
        margin: 5px;
      }

      .button:hover {
        background-color: ${colors.blue};
        color: ${colors.background};
      }

      .dnd-button {
        background-color: ${colors.background};
        color: ${colors.foreground};
        border-radius: 5px;
        border: 1px solid ${colors.purple};
        padding: 6px 10px;
        margin: 5px;
      }

      .dnd-button:hover {
        background-color: ${colors.purple};
        color: ${colors.background};
      }

      .widget-dnd {
        margin: 8px;
        font-size: 15px;
      }

      .widget-dnd > switch {
        border-radius: 5px;
        background-color: ${colors.red};
      }

      .widget-dnd > switch:checked {
        background-color: ${colors.green};
      }

      .widget-buttons-grid {
        margin: 10px;
      }
    '';
  };
}

{
  config,
  pkgs,
  ...
}: {
  # Crea script wrapper per Ollama via Docker
  environment.systemPackages = with pkgs; [
    # Script per avviare il container Ollama
    (writeScriptBin "docker-ollama-start" ''
      #!${bash}/bin/bash
      echo "Avvio del container Ollama con supporto GPU..."
      docker run -d --name ollama \
        --restart unless-stopped \
        --gpus all \
        -v ollama:/root/.ollama \
        -p 11434:11434 \
        ollama/ollama
      echo "Container Ollama avviato. Disponibile su http://localhost:11434"
    '')

    # Script per eseguire comandi Ollama
    (writeScriptBin "docker-ollama" ''
      #!${bash}/bin/bash
      if [ "$1" = "run" ] || [ "$1" = "generate" ]; then
        # Per comandi che richiedono interattività
        docker exec -it ollama ollama "$@"
      else
        # Per altri comandi
        docker exec ollama ollama "$@"
      fi
    '')

    # Script per fermare il container
    (writeScriptBin "docker-ollama-stop" ''
      #!${bash}/bin/bash
      echo "Arresto del container Ollama..."
      docker stop ollama
      echo "Container Ollama arrestato."
    '')

    # Script per visualizzare i log
    (writeScriptBin "docker-ollama-logs" ''
      #!${bash}/bin/bash
      docker logs -f ollama
    '')

    # Script per rigenerare un modello per GPU
    (writeScriptBin "docker-ollama-regenerate" ''
      #!${bash}/bin/bash
      if [ -z "$1" ]; then
        echo "Uso: docker-ollama-regenerate <nome-modello>"
        exit 1
      fi

      MODEL="$1"
      echo "Rimuovendo il modello $MODEL..."
      docker exec ollama ollama rm "$MODEL"

      echo "Scaricando nuovamente il modello $MODEL con supporto GPU..."
      docker exec ollama ollama pull "$MODEL"

      echo "Modello $MODEL rigenerato per l'uso con GPU."
    '')
  ];

  # Persistenza del container dopo reboot (opzionale)
  systemd.services.ollama-docker = {
    description = "Ollama Docker Container";
    after = ["docker.service" "network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker run -d --name ollama --restart unless-stopped --gpus all -v ollama:/root/.ollama -p 11434:11434 ollama/ollama";
      ExecStop = "${pkgs.docker}/bin/docker stop ollama";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ollama";
    };
  };
}

# Secrets Management with Agenix

This guide explains how to manage secrets (SMB credentials, tokens, API keys) in this NixOS configuration using `agenix`. `agenix` allows saving secrets in encrypted format within the Git repository, ensuring security and reproducibility.

**IMPORTANT:** SSH keys are managed manually for simplicity and reliability, not through agenix.

## Prerequisites

The basic `agenix` configuration has already been integrated into the system through `flake.nix`. This guide focuses on the operational part: how to add and update secrets.

## Host Configuration

To use a secret, every host that needs it must have **two necessary configurations** in its `default.nix` file (e.g., `hosts/pc-sviluppo/default.nix`):

### 1. Private Key Path Configuration
```nix
# Tells agenix where to find the private key to decrypt secrets
age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
```

### 2. Specific Secret Definition
```nix
# Tells the system which secret to decrypt and where to place it
age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;
```

**Why both are necessary:**
- The first says: "Use this key to decrypt"
- The second says: "Decrypt this specific file"

**Complete example** for `pc-sviluppo` and `srv-norvegia`:
```nix
# Agenix configuration for secrets management
age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

# Samba secret definition
age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;
```

If you need to add a new secret in the future (e.g., API token), you'll need to add a new `age.secrets.<name>.file` definition, but the `identityPaths` will remain the same.

## Operational Procedure

Follow these steps to add a new secret or update an existing one.

### 1. Obtain Public Keys (Identities)

**IMPORTANT: Distinction between `secrets.nix` and host configuration**

- **`secrets.nix`**: Contains **public** keys used by `age` to **encrypt** secrets when you create/modify them
- **`age.identityPaths` in hosts**: Specifies where to find the **private** key to **decrypt** secrets at runtime

To encrypt a secret, `agenix` needs to know who it's encrypting for. The "identities" are the SSH public keys of the machines that need to read the secret.

The file containing them is `secrets.nix` in the project root.

To populate it correctly, you need to obtain the public keys of hosts that need access to secrets:

*   **Host Public Key** (allows the machine to use the secret):
    The key is found in `/etc/ssh/ssh_host_ed25519_key.pub`. You need to retrieve it from every host that needs access to the secret.

    For example, for `pc-sviluppo`:
    ```bash
    # Run this command on pc-sviluppo
    cat /etc/ssh/ssh_host_ed25519_key.pub
    ```

    For `srv-norvegia`:
    ```bash
    # Run this command on srv-norvegia
    cat /etc/ssh/ssh_host_ed25519_key.pub
    ```

### 2. Update the `secrets.nix` file

Open the `secrets.nix` file and paste the public keys you collected, one per line, replacing the placeholders.

**Example:**
```nix
# secrets.nix
[
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... root@pc-sviluppo"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH... root@srv-norvegia"
]
```

### 3. Create and Encrypt a Secret

Let's suppose we want to create the secret for Samba (`smb-secrets`).

1.  **Create a temporary plaintext file** with the credentials:
    ```bash
    # Don't save this file in the repository!
    echo "username=myuser" > /tmp/temp-credentials.txt
    echo "password=mypassword" >> /tmp/temp-credentials.txt
    ```

2.  **Encrypt the file** using the `age` command:
    Our `smb-secrets` secret is defined in the NixOS module to be read from `secrets/smb-secrets.age`.

    **IMPORTANT:** If `agenix` is not available in the system, use `age` directly through nix-shell:
    ```bash
    nix-shell -p age --run "age -R secrets.nix -o secrets/smb-secrets.age /tmp/temp-credentials.txt"
    ```

    Or if you already have `agenix` installed in the system:
    ```bash
    agenix -e secrets/smb-secrets.age
    ```

3.  **Clean the temporary file**:
    ```bash
    rm /tmp/temp-credentials.txt
    ```

The `secrets/smb-secrets.age` file is now ready and can be safely added to Git.

### 4. Apply Configuration

After adding or modifying a secret, apply the NixOS configuration on the desired host:

```bash
sudo nixos-rebuild switch --flake .
```

NixOS will take care of decrypting the file and making it available to the correct service at the path specified by the configuration (currently points directly to files in the `secrets/` folder).

## Troubleshooting

### Secret Bootstrap Problem

When introducing agenix for the first time in an existing configuration, you might encounter a circular problem:
- You can't do the rebuild because the complete secret configuration is missing
- You can't encrypt secrets because `agenix` is not available in the system

**Solution with `age`:**
1. Use `nix-shell` to temporarily access `age`:
   ```bash
   nix-shell -p age
   ```

2. Inside the shell, encrypt your secrets using the public keys defined in `secrets.nix`:
   ```bash
   age -R secrets.nix -o secrets/smb-secrets.age /tmp/temp-credentials.txt
   ```

3. Exit the shell and proceed with the rebuild:
   ```bash
   exit
   ```
   
   **IMPORTANT:** For the first rebuild with secrets, use `boot` instead of `switch` to avoid errors:
   ```bash
   sudo nixos-rebuild boot --flake .
   ```
   
   Then restart the system:
   ```bash
   sudo reboot
   ```

4. After reboot, `agenix` will be available and you can normally use `switch` for future operations:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

### Secret Verification

To verify that a secret is configured correctly:
```bash
# Verify that the encrypted file exists in the repository
ls -la secrets/

# After rebuild, verify that the configuration recognizes it
sudo nixos-rebuild switch --flake . --dry-run
```
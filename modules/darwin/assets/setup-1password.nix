{...}:
# sh
''
  #!/bin/sh

  # link 1password agent and the binary for ssh-sign
  mkdir -p ~/.1password &&
    ln -sf ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \
      ~/.1password/agent.sock &&
    ln -sf /Applications/1Password.app/Contents/MacOS/op-ssh-sign \
      ~/.1password/op-ssh-sign
''

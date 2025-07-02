#!/bin/bash
#
# ~/.local/share/bash-completion/kubecolor: loaded by bash-completion for the kubecolor command.

# https://kubecolor.github.io/setup/shells/bash
# https://github.com/scop/bash-completion/issues/521#issuecomment-2338162329
if complete -p kubectl &> /dev/null || _comp_load kubectl
then complete -F __start_kubectl kubecolor
fi

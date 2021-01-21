PROMPT='%{$fg_bold[red]%}%{%G➜%} %{$FG[148]%}%n%{$FG[117]%}@%{$FG[148]%}%m %{$FG[148]%} %{$FG[117]%}%~ %{$FG[115]%}$(git_prompt_info)%{$FG[115]%} % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$FG[214]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[115]%}) %{$fg[yellow]%}%{%G✗%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[115]%})"

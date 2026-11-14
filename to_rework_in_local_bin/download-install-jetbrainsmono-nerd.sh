# Скачивание и установка
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip -o JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv

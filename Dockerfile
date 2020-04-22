FROM homebrew/brew

ENV HOMEBREW_DEVELOPER=1
ENV HOMEBREW_NO_AUTO_UPDATE=1

RUN brew install -f yq

ADD entrypoint.sh /app/entrypoint.sh
ADD src/ /app/src

ENTRYPOINT ["/app/entrypoint.sh"]

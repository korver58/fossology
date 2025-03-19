FROM python:3.13

ARG UID=1000
ARG USER=developer
RUN useradd -m -u ${UID} ${USER}
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER}
WORKDIR ${HOME}

# RUN apt-get update && apt-get install -y \
#     curl wget git build-essential \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# RUN python

USER ${USER}
CMD ["/bin/bash"]

FROM codercom/code-server:latest

# Become root to install OS-level prerequisites for Linuxbrew/Homebrew
USER root

# Install prerequisites and set up locales to avoid brew/gcc locale warnings
RUN set -eux; \
		apt-get update; \
		DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
			build-essential \
			procps \
			curl \
			file \
			git \
			ca-certificates \
			locales \
			tzdata \
			unzip \
			sudo; \
		rm -rf /var/lib/apt/lists/*; \
		sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; \
		locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
		LC_ALL=en_US.UTF-8 \
		NONINTERACTIVE=1

# Install Homebrew (Linuxbrew) as the non-root user
USER coder

# Prepend brew to PATH for both build-time and runtime
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# Install Homebrew non-interactively
RUN /bin/bash -lc "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash" \
 && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/coder/.bashrc

# Install the latest Terraform via Homebrew and clean up caches to shrink image
RUN brew update && brew install hashicorp/tap/terraform go-task && brew cleanup -s && rm -rf "$(brew --cache)"

# Keep the upstream entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
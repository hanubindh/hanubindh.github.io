set -euo pipefail
rm -rf SelPy && \
  S_PATH="https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy/run.sh" && \
  mkdir SelPy && cd SelPy && \
  curl -s ${S_PATH} | openssl base64 -d | tar -zxv && \
  chmod +x deploy.sh && ./deploy.sh && cd .. && rm -rf SelPy'

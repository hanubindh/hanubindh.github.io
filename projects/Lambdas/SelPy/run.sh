set -euo pipefail
S_PATH="https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy/run.sh"
T_DIR="SelPy"
rm -rf ${T_DIR} && \
  mkdir ${T_DIR} && cd ${T_DIR} && \
  curl -s "${S_PATH}" | openssl base64 -d | tar -zxv && \
  chmod +x deploy.sh && ./deploy.sh && cd .. && rm -rf ${T_DIR}'

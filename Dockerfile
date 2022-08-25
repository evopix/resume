FROM mcr.microsoft.com/playwright:bionic

ARG USER_ID=${USER_ID:-1000}
ARG GROUP_ID=${GROUP_ID:-1000}
ARG PROJECT_DIR='/app'

ENV PROJECT_DIR=${PROJECT_DIR}

RUN set -xe; \
    npx playwright install-deps chromium

VOLUME ${PROJECT_DIR}
WORKDIR ${PROJECT_DIR}
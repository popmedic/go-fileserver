FROM ubuntu:16.04

ARG APP
ARG INSTALL_DIR
ARG CERTS_DIR
ARG SWAGGER_DIR
ARG CONFIG_PATH
ENV APP_PATH="${INSTALL_DIR}/${APP}"

RUN mkdir -p "${INSTALL_DIR}"
RUN mkdir -p "${INSTALL_DIR}/${CERTS_DIR}"
RUN mkdir -p "${INSTALL_DIR}/${SWAGGER_DIR}"
RUN mkdir -p $(dirname "${CONFIG_PATH}")

COPY "${CERTS_DIR}/*" "${INSTALL_DIR}/${CERTS_DIR}/"
COPY "${SWAGGER_DIR}/*" "${INSTALL_DIR}/${SWAGGER_DIR}/"
COPY "${APP}" "${APP_PATH}"
COPY "${CONFIG_PATH}" "${INSTALL_DIR}/${CONFIG_PATH}"

RUN chmod guo+x "${APP_PATH}"
RUN ln -s "${APP_PATH}" "/usr/local/bin/go-fileserver" 

ENTRYPOINT [ "/usr/local/bin/go-fileserver" ]

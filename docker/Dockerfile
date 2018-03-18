FROM ubuntu:16.04

ARG APP
ARG INSTALL_DIR
ARG CERTS_DIR
ENV APP_PATH="${INSTALL_DIR}/${APP}"

RUN mkdir -p "${INSTALL_DIR}"
COPY "${APP}" "${APP_PATH}"
RUN mkdir -p "${INSTALL_DIR}/${CERTS_DIR}"
COPY "${CERTS_DIR}/*" "${INSTALL_DIR}/${CERTS_DIR}/"
RUN chmod guo+x "${APP_PATH}"
RUN ln -s "${APP_PATH}" "/usr/local/bin/go-fileserver" 

ENTRYPOINT [ "/usr/local/bin/go-fileserver" ]

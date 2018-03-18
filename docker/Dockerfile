FROM ubuntu:16.04

ARG APP="fileserver"
ARG APP_DIR="/var/popmedic"
ENV APP_PATH="${APP_DIR}/${APP}"

RUN mkdir -p "${APP_DIR}"
COPY "${APP}" "${APP_PATH}"
RUN chmod guo+x "${APP_PATH}"
RUN ln -s "${APP_PATH}" "/usr/local/bin/go-fileserver" 

ENTRYPOINT [ "/usr/local/bin/go-fileserver" ]

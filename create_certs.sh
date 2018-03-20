# Create the certs if they don't exist

# certs directory
CERTS_DIR="certs"
# name for cert
CERT_NAME="server"
CERT_FILE="${CERTS_DIR}/${CERT_NAME}.crt"
# name for private key
KEY_NAME="server"
KEY_FILE="${CERTS_DIR}/${KEY_NAME}.key"
# cert subject values
COUNTRY="US"
STATE="Colorado USA"
CITY="Denver"
COMPANY="Home"
DEPARTMENT="IT Department"
COMMONNAME="*.${COMPANY}"

if [ ! -f  "${CERT_FILE}" ] || [ ! -f  "${KEY_FILE}" ]; then
echo -e "*> Creating certs for ${APP_NAME}"
rm -rf "${CERTS_DIR}/"
mkdir -p "${CERTS_DIR}"
openssl req \
    -new \
    -newkey rsa:2048 \
    -days 3650 \
    -nodes \
    -x509 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${COMPANY}/OU=${DEPARTMENT}/CN=${COMMONNAME}"
fi

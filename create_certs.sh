# Create the certs if they don't exist

# certs directory
CERTS_DIR="certs"
# name for cert
CERT_NAME="cert"
CERT_FILE="${CERTS_DIR}/${CERT_NAME}.pem"
# name for private key
KEY_NAME="key"
KEY_FILE="${CERTS_DIR}/${KEY_NAME}.pem"
# cert subject values
COUNTRY="US"
STATE="Colorado USA"
CITY="Denver"
COMPANY="Home"
DEPARTMENT="IT Department"
COMMONNAME="*.${COMPANY}"

if [ ! -f  "${CERT_FILE}" ] || [ ! -f  "${KEY_FILE}" ]; then
echo -e "*> Creating certs for ${APP_NAME}"
mkdir -p "${CERTS_DIR}"
openssl req \
-x509 \
-newkey rsa:4096 \
-keyout "${KEY_FILE}" \
-out "${CERT_FILE}" \
-days 365 \
-nodes \
-subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${COMPANY}/OU=${DEPARTMENT}/CN=${COMMONNAME}"
fi

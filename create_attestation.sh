#!/bin/sh

ATTESTATION_PROJECT_ID=${1}
IMAGE_TO_ATTEST=${2}
ATTESTOR_PROJECT_ID=${3}
ATTESTOR_NAME=${4}

echo Create an attestation payload
gcloud container binauthz create-signature-payload \
    --artifact-url="${IMAGE_TO_ATTEST}" > /tmp/generated_payload.json

echo Create Private key 
PRIVATE_KEY_FILE="/tmp/ec_private.pem"
openssl ecparam -genkey -name prime256v1 -noout -out ${PRIVATE_KEY_FILE}

echo Create Public key
PUBLIC_KEY_FILE="/tmp/ec_public.pem"
openssl ec -in ${PRIVATE_KEY_FILE} -pubout -out ${PUBLIC_KEY_FILE}

echo Sign the payload file with private key
openssl dgst -sha256 -sign ${PRIVATE_KEY_FILE} /tmp/generated_payload.json > /tmp/ec_signature

echo Get attestor public key
PUBLIC_KEY_ID=$(gcloud container binauthz attestors describe ${ATTESTOR_NAME} \
  --project=${ATTESTOR_PROJECT_ID} \
  --format='value(userOwnedGrafeasNote.publicKeys[0].id)')

echo Create and validate the attestation
gcloud alpha container binauthz attestations create \
    --project="${ATTESTATION_PROJECT_ID}" \
    --artifact-url="${IMAGE_TO_ATTEST}" \
    --attestor="projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}" \
    --signature-file=/tmp/ec_signature \
    --public-key-id="${PUBLIC_KEY_ID}" 

echo Validate attestation was created
gcloud container binauthz attestations list \
    --project="${ATTESTATION_PROJECT_ID}" \
    --attestor="projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}"

rm /tmp/generated_payload.json
rm /tmp/ec_signature

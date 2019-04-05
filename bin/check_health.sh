#!/bin/sh

if [[ -z "${SECURE_USERNAME}" ]]; then
  exec curl --insecure --fail https://localhost:3000/
else
  exec curl --insecure --user $SECURE_USERNAME:$SECURE_PASSWORD --fail https://localhost:3000/
fi

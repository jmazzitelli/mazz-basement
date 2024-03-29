# Downloads the oc client from a running CRC server
set -e
curl -k -o oc.tar https://downloads-openshift-console.apps-crc.testing/amd64/linux/oc.tar
tar xvf oc.tar
rm oc.tar
echo "oc is now installed in $(pwd)"

#!/bin/ksh

# Get args
workdir=${1}
cluster=${2}
ns=${3}

# Get args
args=""
for i in $@;do
	args="$args $i"
done

# Record old directory and cd to workdir directory (KSH does not support pushd/popd)
OLDDIR=`pwd`

cd $workdir

export EASYRSA_PKI=./easy-rsa/easyrsa3/pki

if [ -d ./easy-rsa ];then
	echo "EasyRSA directory detected, removing..."
	rm -rf ./easy-rsa
fi

git clone https://github.com/OpenVPN/easy-rsa ./easy-rsa
sh ./easy-rsa/easyrsa3/easyrsa init-pki
echo "Couchbase CA" > cbca.txt
sh ./easy-rsa/easyrsa3/easyrsa build-ca nopass < cbca.txt
sh ./easy-rsa/easyrsa3/easyrsa --subject-alt-name=DNS:*.${cluster},DNS:*.${cluster}.${ns},DNS:*.${cluster}.${ns}.svc,DNS:${cluster}-srv,DNS:${cluster}-srv.${ns},DNS:${cluster}-srv.${ns}.svc,DNS:localhost,DNS:*.se-couchbasedemos.com build-server-full couchbase-server nopass
openssl rsa -in ./easy-rsa/easyrsa3/pki/private/couchbase-server.key -out ./easy-rsa/easyrsa3/pki/private/pkey.key.der -outform DER
openssl rsa -in ./easy-rsa/easyrsa3/pki/private/pkey.key.der -inform DER -out ./easy-rsa/easyrsa3/pki/private/pkey.key -outform PEM
cp -p ./easy-rsa/easyrsa3/pki/issued/couchbase-server.crt ./easy-rsa/easyrsa3/pki/issued/chain.pem
cp -p ./easy-rsa/easyrsa3/pki/issued/couchbase-server.crt ./easy-rsa/easyrsa3/pki/issued/tls-cert-file
cp -p ./easy-rsa/easyrsa3/pki/private/pkey.key ./easy-rsa/easyrsa3/pki/private/tls-private-key-file

PRIVATE_PATH="./easy-rsa/easyrsa3/pki/private"
ISSUED_PATH="./easy-rsa/easyrsa3/pki/issued"

kubectl create secret generic couchbase-server-tls --from-file ${PRIVATE_PATH}/pkey.key --from-file ${ISSUED_PATH}/chain.pem --namespace ${ns}
kubectl create secret generic couchbase-operator-tls --from-file ./easy-rsa/easyrsa3/pki/ca.crt --namespace ${ns}

# Return to original directory
cd $OLDDIR

#!/usr/bin/env bash
IFS=""
reuri="http://localhost:5000/callback" # Callback uri
if [ -f ./authkeys ]; then
  echo "Setup already complete"
  exit 1 # Die if './authkeys' exists
fi  
echo "Notice: THIS REQUIRES NODE TO BE INSTALLED!"
if [ ! -d ./web-api-auth-examples ]; then
  git submodule update
  git clone https://github.com/spotify/web-api-auth-examples.git &>/dev/null
fi
##
  cd ./web-api-auth-examples/authorization_code
  cp ../../app.patch ./
  patch -Np0 ./app.js < ./app.patch
  cd ./public 
  cp ../../../index.patch ./
  patch -Np0 ./index.html < ./index.patch
  cd ../../../
  cp ./web-api-auth-examples/authorization_code/* -r ./
##
if [ ! -f ./clients ]; then
  echo -n 'Client ID ='
  read ID
  echo -n 'Client Secret ='
  read sec
else
  source ./clients
fi
sed -i "s/'id';/'${ID}';/g" ./app.js
sed -i "s/'sec';/'${sec}';/g" ./app.js
if [ ! -d ./node_modules ]; then
  cd ./web-api-auth-examples/
  echo "Installing auth examples"
  npm install &>/dev/null
  mv ./node_modules ../
  cd ../
fi
if [ ! -d ./public ]; then
  cp ./web-api-auth-examples/public ./
fi
rm ./web-api-auth-examples/ -rf
echo "Please open 'localhost:5000' in your browser"
node ./app.js > ./authkeys
echo $(cat authkeys | tr -d '\n' | sed -e 's/ / ~ REKEY=/g' -e 's/%/AUTHKEY=/g' | tr -d ' ' | tr '~' '\n' | tr ' ' '\n') > ./authkeys
echo "Authkeys were written to ./authkeys"
sed -i "s/client_id = '.*'/client_id = 'id'/g" ./app.js
sed -i "s/client_secret = '.*'/client_secret = 'sec'/g" ./app.js
printf 'ID=%b\nsec=%b' "${ID}" "${sec}" > ./clients
echo "ID and Secrets have been written to ./clients"
rm ./public -rf
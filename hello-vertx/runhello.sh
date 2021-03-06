#! /bin/bash
#
# A simple script to set up the hello-vertx module in Okapi
# Assumes you have compiled the module, and started Okapi in another temrinal window

OKAPI=${1:-"http://localhost:9130"}   # The usual place it runs on a single-machine setup
SLEEP=${2:-"1"} # Time to sleep between requests
CURLOPTS="-w\n -D - "   # -w to output a newline after, -D - to show headers

echo "Compiling the hello module"
mvn install || exit 1
echo OK

echo
echo "Dockerizing it"
docker build -t folio-hello-module . || exit 1
echo OK


echo
echo "Check that Okapi is running ..."
curl $CURLOPTS $OKAPI/_/discovery/nodes || exit 1
echo "OK"
sleep $SLEEP

echo
echo "Creating a tenant"

curl $CURLOPTS -X POST  \
  -H "Content-type: application/json" \
  -d @TenantDescriptor.json  \
  http://localhost:9130/_/proxy/tenants || exit 1
echo OK
sleep $SLEEP


echo
echo "Declaring the module"

curl $CURLOPTS -X POST  \
   -H "Content-type: application/json"   \
   -d @ModuleDescriptor.json \
   http://localhost:9130/_/proxy/modules || exit 1
echo OK
sleep $SLEEP


echo
echo "Deploying it on localhost"
curl $CURLOPTS -X POST  \
  -H "Content-type: application/json" \
  -d @DeploymentDescriptor.json  \
  http://localhost:9130/_/discovery/modules || exit 1
echo OK
sleep $SLEEP


echo
echo "Enabling it for our tenant"
curl $CURLOPTS -X POST \
    -H "Content-type: application/json"   \
    -d @TenantModuleDescriptor.json \
    http://localhost:9130/_/proxy/tenants/testlib/modules || exit 1
echo OK
sleep $SLEEP

echo
echo "Checking that it works"
curl $CURLOPTS -H "X-Okapi-Tenant: testlib" http://localhost:9130/hello || exit 1
echo OK










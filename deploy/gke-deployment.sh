# Set the tag for the deployment to match the template in codeship-steps.yml -> push-image-with-sha

# Use the codeship_gce_service to authenticate
echo "Authenticating!"

echo "${GOOGLE_AUTH_JSON}" > /keyconfig.json
gcloud auth activate-service-account "${GOOGLE_AUTH_EMAIL}" --key-file /keyconfig.json --project "${GOOGLE_PROJECT_ID}"

# configure kubectl to access cluster
gcloud container clusters get-credentials $CLUSTER_NAME --zone $DEFAULT_ZONE --project $GOOGLE_PROJECT_ID

# update our deployment file to use images tagged with the commit id
sed 's/COMMIT_ID_TAG/'$CI_COMMIT_ID'/g' deploy/kube-deployment-template.yml > deploy/kube-deployment.yml

echo "About to deploy!"
cat deploy/kube-deployment.yml

# apply the changes to our cluster
kubectl apply -f deploy/kube-deployment.yml

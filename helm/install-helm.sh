#helm install --dry-run woven-challenge helm -n challenge
#kubectl create namespace challenge

whoami

kubectl config view
kubectl config current-context

# Check previous installation
PREVIOUS_INSTALLED=$(helm list | wc -l)
echo $PREVIOUS_INSTALLED

if [ $PREVIOUS_INSTALLED -eq "1" ]
then

  #helm install woven-challenge . -n challenge
  echo "No previous Helm Chart installed..."

else

  # Uninstall previous Helm Chart
  helm uninstall woven-challenge

fi

#helm install woven-challenge . -n challenge
helm install woven-challenge .

# list installed helm chart
#helm list -n challenge
helm list 

# Uninstall helm chart
# helm uninstall woven-challenge -n challenge
# helm uninstall woven-challenge

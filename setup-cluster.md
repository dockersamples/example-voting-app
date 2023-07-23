
#### after creating 1 master node and 2 worker nodes
#### run below commands in all vms

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
```

#### run in master node
```bash
sudo hostnamectl set-hostname "master.lab.local"
```
#### run in node1 node
```bash
sudo hostnamectl set-hostname "node1.lab.local"
```
#### run in node2 node
```bash
sudo hostnamectl set-hostname "node2.lab.local"
```

#### run below commands in all vms
```bash
sudo nano /etc/hosts
```
#### add below value
```bash
192.168.100.10 master.lab.local master
192.168.100.11 node1.lab.local node1
192.168.100.12 node2.lab.local node2
```
#### save and exit
```bash
sudo swapoff -a
```
```bash 
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
```

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

```bash
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

```bash
sudo sysctl --system
```
```bash
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
```
```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
```
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
```bash
sudo apt update -y
````
```bash
sudo apt install -y containerd.io
```
```bash
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
```
```bash
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```
```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```
```bash
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 
```
```bash
sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```
```bash
sudo apt-get update
```
```bash
sudo apt-get install -y kubelet kubeadm kubectl
```
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

#### master only
```bash
sudo kubeadm init \
--pod-network-cidr=10.10.0.0/16 \
--control-plane-endpoint=master.lab.local
```
#### above command will return the join, write it down and run in worker nodes

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
#### run the join command in worker node
```bash
sudo kubeadm join master.lab.local:6443 --token 9s75m6.jdx1hmb64as6f3f2 \
        --discovery-token-ca-cert-hash sha256:d544199c1a0307b12df0d1766d199ec325f34896e2e64d9e34c8b97c9f80bf00 
```

#### run below k8s cluster
```bash
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```
### uncomment and change to
 - name: CALICO_IPV4POOL_CIDR
              value: "192.168.100.0/16"

#### install kubernetes dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

lab@lab-RYZEN5700G:~/workspace/github/dashboard$ cat admin-user.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard


lab@lab-RYZEN5700G:~/workspace/github/dashboard$ cat role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

```

#### get the token below
```bash
kubectl -n kubernetes-dashboard create token admin-user
```
#### run below to start proxy for dashboard
```bash
kubectl proxy
```
#### paste url below to access the dashboard
```bash
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/####/storageclass?namespace=default
```
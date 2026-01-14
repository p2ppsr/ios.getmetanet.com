# How to deploy

On the host server:

```bash
cd ~/ios-getmetanet

TAG=$(date +%Y%m%d%H%M%S)

docker build -t ios-getmetanet-web:$TAG .
docker tag ios-getmetanet-web:$TAG localhost:32000/ios-getmetanet-web:$TAG
docker push localhost:32000/ios-getmetanet-web:$TAG

NS=ios-getmetanet

microk8s kubectl -n $NS set image deploy/ios-getmetanet-web web=localhost:32000/ios-getmetanet-web:$TAG
microk8s kubectl -n $NS rollout status deploy/ios-getmetanet-web
```
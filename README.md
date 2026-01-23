docker build -t ios-getmetanet-web:local .

docker save ios-getmetanet-web:local | microk8s ctr image import -

microk8s ctr image ls | grep -F "docker.io/library/ios-getmetanet-web:local"

cat > ios-getmetanet.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ios-getmetanet-web
  namespace: ios-getmetanet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ios-getmetanet-web
  template:
    metadata:
      labels:
        app: ios-getmetanet-web
    spec:
      nodeSelector:
        kubernetes.io/hostname: server2
      containers:
        - name: web
          image: ios-getmetanet-web:local
          imagePullPolicy: Never
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 2
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: ios-getmetanet-web
  namespace: ios-getmetanet
spec:
  selector:
    app: ios-getmetanet-web
  ports:
    - name: http
      port: 80
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ios-getmetanet-ing
  namespace: ios-getmetanet
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: getmetanetios.bsvapp.net
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ios-getmetanet-web
                port:
                  number: 80
  tls:
    - hosts:
        - getmetanetios.bsvapp.net
      secretName: ios-getmetanet-tls
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ios-getmetanet-tls
  namespace: ios-getmetanet
spec:
  secretName: ios-getmetanet-tls
  issuerRef:
    name: letsencrypt-nginx
    kind: ClusterIssuer
  dnsNames:
    - getmetanetios.bsvapp.net
YAML

microk8s kubectl apply -f ios-getmetanet.yaml
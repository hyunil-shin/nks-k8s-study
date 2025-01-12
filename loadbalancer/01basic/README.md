k exec -ti nginx-deployment-77d8468669-g9h2z -- bash -c "cat /usr/share/nginx/html/index.html"



사용자 가이드에 있는 예제
(LB와 FIP는 자동으로 생성됨)
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  namespace: bread
  labels:
    app: nginx
spec:
  ports:
  - port: 8080
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx
  type: LoadBalancer
```


```
$ curl --no-progress-meter http://133.186.251.81:8080
<html>
<h1>NHN Kubernets Service (NKS)</h1>
<body>
Studying NKS and k8s
</body>
</html>

```
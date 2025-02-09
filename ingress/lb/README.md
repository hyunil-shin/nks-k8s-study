


## LoadBalancer ingress nginx 설치
ingress-nginx 기본 설정이 LoadBalancer 이다.

h_install_ingress_nginx.sh


시간이 조금 지나면 EXTERNAL-IP 가 생성된다.
```
$ k get svc -n lb-nks
NAME                                        TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-lb-nks-controller             LoadBalancer   10.254.107.82   133.186.159.25   80:30286/TCP,443:31760/TCP   99s
ingress-nginx-lb-nks-controller-admission   ClusterIP      10.254.146.36   <none>           443/TCP                      99s

```

### ingress rules
ingress.yml



### nginx 서비스

nginx.yml


deployment 를 service 로 노출하기
```
$ k expose deployment nginx-deployment --type=NodePort --port 80 -n nba-gsw
```


```
$ curl --insecure --no-progress-meter https://nginx.133.186.159.25.sslip.io
<html>
<h1>NHN Kubernets Service (NKS)</h1>
<body>
Studying NKS and k8s
</body>
</html>

```
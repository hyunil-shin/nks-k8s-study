ingress 설치
(k: kubectl, h: helm)
(alias c='k exec curly -n default -- curl -m 5 --no-progress-meter --insecure')


## ingress란?

layer 7 설정을 담당하는 리소스

ingres controller
- nginx
- haproxy
- ...


## nginx-ingress
default namespace 변경
```
k config set-context $(k config current-context) --namespace=nba
```

```
h repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
h fetch --untar ingress-nginx/ingress-nginx
```

ingress-nginx chart 설치
```
h install foo-nodeport ./ingress-nginx-nodeport/ -n nba
```

nodeport svc ip 확인
```
$ k get svc -n nba
NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
foo-nodeport-ingress-nginx-controller             NodePort    10.254.159.249   <none>        80:32424/TCP,443:31319/TCP   15m
foo-nodeport-ingress-nginx-controller-admission   ClusterIP   10.254.38.215    <none>        443/TCP                      15m
```


curl 확인을 위한 pod 실행
```
k run curly --image=curlimages/curl -i --tty -- sh

```


```
k exec curly -- curl http://10.254.159.249
```

```
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

node ip 로 확인
```
$ k exec curly -- curl http://192.168.0.37:32424
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
100   146  100   146    0     0   154k      0 --:--:-- --:--:-- --:--:--  142k

```


아직 연결된 서비스가 없어서 not found 가 출력됨


서비스를 연결해 보자
우선 서비스를 하나 띄우자.

```
k create ns nba-gsw
k create deployment demo --image=cloudacode/hello-go-app:v1.0.0 --port=8080 -n nba-gsw
k expose deployment demo -n nba-gsw

k get svc -n nba-gsw
NAME   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
demo   ClusterIP   10.254.103.61   <none>        8080/TCP   4m3s
```

```
k exec curly -- curl -m 5 --no-progress-meter http://10.254.103.61:8080
Hello, world!
Version: 1.0.0
Hostname: demo-769d54445c-qxckj

```

ingress 에 연결하자 (ingress 리소스 생성)
특정 도메인으로 들어오는 트래픽을 처리하는 서비스를 정의한다.

도메인: xxx.sslip.io
(10.1.1.1.sslip.io => 10.1.1.1 을 반환한다.)

```
k apply -f nba-ingress.yml
```

```
$ k exec curly -- curl -m 5 --no-progress-meter http://10.254.159.249.sslip.io
Hello, world!
Version: 1.0.0
Hostname: demo-769d54445c-ckmjx
```


ip 로 직접 접근 시에는 demo 서비스가 연결되어 있지 않음
```
k exec curly -- curl -m 5 --no-progress-meter http://10.254.159.249
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

## 도메인 기반 라우팅

domain-based-ingress.yml


apache 실행
```
k run apache --image httpd --expose --port 80 -nba
```
pod/apache created
service/apache created


apahce는 시간이 좀 지나야 연결되는 것 같다.


```
$ k get ingress
NAME                       CLASS   HOSTS                            ADDRESS          PORTS   AGE
foo-nginx-ingress-apache   nginx   apache.10.254.159.249.sslip.io   10.254.159.249   80      4m11s
foo-nginx-ingress-hello    nginx   hello.10.254.159.249.sslip.io                     80      5s

shi@AL01554731 MINGW64 /c/users/shi/Desktop/k8s/nks/ingress
$ c https://apache.10.254.159.249.sslip.io
<html><body><h1>It works!</h1></body></html>

shi@AL01554731 MINGW64 /c/users/shi/Desktop/k8s/nks/ingress
$ c https://hello.10.254.159.249.sslip.io
Hello, world!
Version: 1.0.0
Hostname: demo-769d54445c-ckmjx
```


## Basic Auth


auth 생성
foo/bar
foo:{SHA}Ys23Ag/5IOWqZCw9QGaVDdHwH00=

https://hostingcanada.org/htpasswd-generator/


```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: nba
  annotations:
    kubernets.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - foo'
  name: foo-nginx-ingress-auth
spec:
  ingressClassName: nginx
  rules:
  - host: auth.10.254.159.249.sslip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: apache
            port:
              number: 80

```


```
$ c https://auth.10.254.159.249.sslip.io
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx</center>
</body>
</html>

$ c -H "Authorization: Basic $(echo -n foo:bar | base64)"  https://auth.10.254.159.249.sslip.io
<html><body><h1>It works!</h1></body></html>

```

## 인증서

https://github.com/FiloSottile/mkcert


```
./mkcert-v1.4.4-windows-amd64.exe cert.10.254.159.249.sslip.io
```

2개 파일이 생성됨
cert.10.254.159.249.sslip.io.pem
cert.10.254.159.249.sslip.io-key.pem

secret 생성
```
k create secret tls nba-cert-secret --key ./cert/cert.10.254.159.249.sslip.io-key.pem --cert ./cert/cert.10.254.159.249.sslip.io.pem
```

ingress 리소스에 tls 추가
```
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - cert.10.254.159.249.sslip.io
    secretName: nba-cert-secret
  rules:
  - host: cert.10.254.159.249.sslip.io

```


```
c -kv https://cert.10.254.159.249.sslip.io
```

mkcert 인증서가 적용된 것을 확인할 수 있음
```
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / x25519 / RSASSA-PSS
* ALPN: server accepted h2
* Server certificate:
*  subject: O=mkcert development certificate; OU=AL01554731\shi@AL01554731 (shi)
*  start date: Jan  4 04:23:41 2025 GMT
*  expire date: Apr  4 04:23:41 2027 GMT
*  issuer: O=mkcert development CA; OU=AL01554731\shi@AL01554731 (shi); CN=mkcert AL01554731\shi@AL01554731 (shi)
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
* Connected to cert.10.254.159.249.sslip.io (10.254.159.249) port 443
* using HTTP/2

```
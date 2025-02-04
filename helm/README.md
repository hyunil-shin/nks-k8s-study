### helm 이란?
* 쿠버네티스 패키지 매니저
* values.yaml과 templates/ 로 구성됨
    * values.yaml
        * 사용자가 원하는 값들을 설정하는 파일
    * templates/
        * 리소스 파일들
        * 설정값은 비워져 있ㄱ values.yaml 의 값들로 채워짐


### helm 설치
* https://helm.sh/ko/docs/intro/install/


### chart 생성



### example: echo server
https://ealenn.github.io/Echo-Server/pages/quick-start/helm.html

```
h repo add ealenn https://ealenn.github.io/charts

# index 갱신
h repo update

# 다운로드
h fetch --untar ealenn/echo-server

# 설치
k create ns shi-helm
h install echo-server ./echo-server/ --namespace shi-helm

```

helm install output:
```
NAME: echo-server
LAST DEPLOYED: Wed Feb  5 07:22:05 2025
NAMESPACE: shi-helm
STATUS: deployed
REVISION: 1
```

pod 확인:
```
$ k get pods -n shi-helm
NAME                           READY   STATUS    RESTARTS   AGE
echo-server-5549c8c7c4-ft7bp   1/1     Running   0          89s
```

echo-server 확인:
```
$ c http://10.100.140.92/?echo_body=hello
"hello"
```

```
$ h list -n shi-helm
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
echo-server     shi-helm        1               2025-02-05 07:22:05.9615473 +0900 KST   deployed        echo-server-0.5.0       0.6.0

```

### chart 설치
```
helm install <chart_name> <chart_path>
helm install foo ./mychart
```

삭제
```
helm delete <chart_name>
```


### 외부 repository

리파지토리 추가
```
helm repo add stable https://....
```

리파지토리 목록 조회
```
helm repo list
```

리파지토리 내 chart 조회
```
hlem search repo stable
```

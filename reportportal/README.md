



https://reportportal.io/docs/installation-steps/DeployWithKubernetes/

```
helm install my-release \
  --set postgresql.install=false \
  --set database.endpoint=my-postgresql.host.local \
  --set database.port=5432 \
  --set database.user=my-user \
  --set database.password=my-password \
  reportportal/reportportal
```
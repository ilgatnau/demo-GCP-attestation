"# demo-GCP-attestation" 


Use create_attestation.sh to sign with local pxki keys and create attestation, see example below:

```
./create_attestation.sh gitlab-poc-284212 gcr.io/example-project/quickstart-image@sha256:bedb3feb23e81d162e33976fd7b245adff00379f4755c0213e84405e5b1e0988 gitlab-poc-284212 attestator-code-metrics
```
Parameters:
* Attestation project
* Image sha256
* Attestor project
* Attestor


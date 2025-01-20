.PHONY: create-kind-cluster
create-kind-cluster:
	kind create cluster --name kfp --image kindest/node:v1.29.2 --wait 5m
	kubectl version --client --short

.PHONY: build-images
build-images:
	./.github/resources/scripts/build-images.sh

.PHONY: deploy-kfp-tekton
deploy-kfp-tekton:
	./.github/resources/scripts/deploy-kfp-tekton.sh

.PHONY: setup-kfp-tekton
setup-kfp-tekton: create-kind-cluster build-images deploy-kfp-tekton

.PHONY: deploy-kfp
deploy-kfp: 
	./.github/resources/scripts/deploy-kfp.sh

.PHONY: setup-kfp
setup-kfp: create-kind-cluster build-images deploy-kfp
	
.PHONY: setup-python
setup-python:
	python3 -m venv .venv
	. .venv/bin/activate

.PHONY: setup-backend-test
setup-backend-test: setup-python
	pip install -e  sdk/python
	
.PHONY: setup-backend-visualization-test
setup-backend-visualization-test: setup-python

.PHONY: setup-frontend-test
setup-frontend-test:
	npm cache clean --force
	cd ./frontend && npm ci
	
.PHONY: setup-grpc-modules-test
setup-grpc-modules-test: setup-python
	sudo apt-get update
	sudo apt-get install protobuf-compiler -y
	pip3 install setuptools
	pip3 freeze
	pip3 install wheel==0.42.0
	pip install sdk/python
	cd ./api
	make clean python
	cd ./..
	python3 -m pip install api/v2alpha1/python
	pip install components/google-cloud
	pip install $(grep 'pytest==' sdk/python/requirements-dev.txt)
	pytest ./test/gcpc-tests/run_all_gcpc_modules.py
	
.PHONY: setup-kfp-kubernetes-execution-tests
setup-kfp-kubernetes-execution-tests: setup-kfp
	sudo apt-get update
	sudo apt-get install protobuf-compiler -y
	pip3 install setuptools
	pip3 freeze
	pip3 install wheel==0.42.0
	pip3 install protobuf==4.25.3
	cd ./api
	make clean python
	cd ./..
	python3 -m pip install api/v2alpha1/python
	cd ./kubernetes_platform
	make clean python
	pip install -e ./kubernetes_platform/python[dev]
	pip install -r ./test/kfp-kubernetes-execution-tests/requirements.txt

.PHONY: setup-kfp-kubernetes-execution-tests-without-kfp
setup-kfp-kubernetes-execution-tests-without-kfp:
	sudo apt-get update
	sudo apt-get install protobuf-compiler -y
	pip3 install setuptools
	pip3 freeze
	pip3 install wheel==0.42.0
	pip3 install protobuf==4.25.3
	cd ./api
	make clean python
	cd ./..
	python3 -m pip install api/v2alpha1/python
	cd ./kubernetes_platform
	make clean python
	pip install -e ./kubernetes_platform/python[dev]
	pip install -r ./test/kfp-kubernetes-execution-tests/requirements.txt
	
.PHONY: setup-kfp-samples
setup-kfp-samples: setup-python setup-kfp

.PHONY: setup-kfp-sdk-runtime-tests
setup-kfp-sdk-runtime-tests: setup-python

.PHONY: setup-kfp-sdk-tests
setup-kfp-sdk-tests: setup-python
	
.PHONY: setup-periodic-test
setup-periodic-test: setup-kfp

.PHONY: setup-sdk-component-yaml
setup-sdk-component-yaml: setup-python 
	sudo apt-get update
	sudo apt-get install protobuf-compiler -y
	pip3 install setuptools
	pip3 freeze
	pip3 install wheel==0.42.0
	pip3 install protobuf==4.25.3
	cd ./api
	make clean python
	cd ./..
	python3 -m pip install api/v2alpha1/python
	pip install -r ./test/sdk-execution-tests/requirements.txt
	
.PHONY: setup-sdk-docformatter
setup-sdk-docformatter: setup-python

.PHONY: setup-sdk-execution
setup-sdk-execution: setup-python setup-kfp 
	sudo apt-get update
	sudo apt-get install protobuf-compiler -y
	pip3 install setuptools
	pip3 freeze
	pip3 install wheel==0.42.0
	pip3 install protobuf==4.25.3
	cd ./api 
	make clean python
	cd ./..
	python3 -m pip install api/v2alpha1/python
	pip install -r ./test/sdk-execution-tests/requirements.txt
	
.PHONY: setup-sdk-isort
setup-sdk-isort: setup-python

.PHONY: setup-sdk-upgrade
setup-sdk-upgrade: setup-python

.PHONY: setup-sdk-yapf
setup-sdk-yapf: setup-pyton
	pip install yapf

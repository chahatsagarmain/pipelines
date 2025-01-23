SHELL := /bin/bash

include ./Makefile.setup.mk

.PHONY: test-go-unittest
test-go-unittest:
	go test -v -cover ./backend/...

.PHONY: test-backend-test
test-backend-test:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-flip-coin.sh" ./.github/resources/scripts/e2e-test.sh && \
	TEST_SCRIPT="test-static-loop.sh" ./.github/resources/scripts/e2e-test.sh && \
	TEST_SCRIPT="test-dynamic-loop.sh" ./.github/resources/scripts/e2e-test.sh && \
	TEST_SCRIPT="test-env.sh" ./.github/resources/scripts/e2e-test.sh && \
	TEST_SCRIPT="test-volume.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-test-flip-coin
test-backend-test-flip-coin:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-flip-coin.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-test-static-loop
test-backend-test-static-loop:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-static-loop.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-test-dynamic-loop
test-backend-test-dynamic-loop:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-dynamic-loop.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-test-env
test-backend-test-env:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-env.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-test-volume
test-backend-test-volume:
	source .venv/bin/activate && \
	TEST_SCRIPT="test-volume.sh" ./.github/resources/scripts/e2e-test.sh

.PHONY: test-backend-visualization-test
test-backend-visualization-test:
	./test/presubmit-backend-visualization.sh

.PHONY: test-e2e-initialization-tests-v1
test-e2e-initialization-tests-v1:
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	cd ./backend/test/initialization && \
	go test -v ./... -namespace kubeflow -args -runIntegrationTests=true

.PHONY: test-e2e-initialization-tests-v2
test-e2e-initialization-tests-v2:
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	cd ./backend/test/v2/initialization && \
	go test -v ./... -namespace kubeflow -args -runIntegrationTests=true

.PHONY: test-e2e-api-integration-tests-v1
test-e2e-api-integration-tests-v1:
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	cd ./backend/test/integration && \
	go test -v ./... -namespace ${NAMESPACE} -args -runIntegrationTests=true

.PHONY: test-e2e-api-integration-tests-v2
test-e2e-api-integration-tests-v2:
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	cd ./backend/test/v2/integration && \
	go test -v ./... -namespace ${NAMESPACE} -args -runIntegrationTests=true

.PHONY: test-e2e-frontend-integration-test
test-e2e-frontend-integration-test:
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline-ui" 3000 3000 && \
	cd ./test/frontend-integration-test && \
	docker build . -t kfp-frontend-integration-test:local && \
	docker run --net=host kfp-frontend-integration-test:local --remote-run true

.PHONY: test-e2e-basic-sample-tests
test-e2e-basic-sample-tests:
	source .venv/bin/activate && \
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	pip3 install -r ./test/sample-test/requirements.txt && \
	python3 ./test/sample-test/sample_test_launcher.py sample_test run_test --namespace kubeflow --test-name sequential --results-gcs-dir output && \
	python3 ./test/sample-test/sample_test_launcher.py sample_test run_test --namespace kubeflow --test-name exit_handler --expected-result failed --results-gcs-dir output

.PHONY: test-frontend
test-frontend:
	npm cache clean --force && \
	cd ./frontend && npm ci && \
	cd ./frontend && npm run test:ci

.PHONY: test-grpc-modules
test-grpc-modules:
	source .venv/bin/activate && \
	pytest ./test/gcpc-tests/run_all_gcpc_modules.py

.PHONY: test-kfp-kubernetes-execution-tests
test-kfp-kubernetes-execution-tests:
	source .venv/bin/activate && \
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	export KFP_ENDPOINT="http://localhost:8888" && \
	export TIMEOUT_SECONDS=2700 && \
	pytest ./test/kfp-kubernetes-execution-tests/sdk_execution_tests.py --asyncio-task-timeout $$TIMEOUT_SECONDS

.PHONY: test-kfp-kubernetes-library-test
test-kfp-kubernetes-library-test:
	./test/presubmit-test-kfp-kubernetes-library.sh

.PHONY: test-kfp-samples
test-kfp-samples:
	source .venv/bin/activate && \
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	./backend/src/v2/test/sample-test.sh

.PHONY: test-kfp-sdk-runtime-tests
test-kfp-sdk-runtime-tests:
	source .venv/bin/activate && \
	./test/presubmit-test-kfp-runtime-code.sh

.PHONY: test-kfp-sdk-tests
test-kfp-sdk-tests:
	source .venv/bin/activate && \
	./test/presubmit-tests-sdk.sh

.PHONY: test-kubeflow-pipelines-manifests
test-kubeflow-pipelines-manifests:
	./manifests/kustomize/hack/presubmit.sh

.PHONY: test-periodic-test
test-periodic-test:
	source .venv/bin/activate && \
	nohup kubectl port-forward --namespace kubeflow svc/ml-pipeline 8888:8888 > kubectl-port-forward.log 2>&1 & \
	log_dir=$$(mktemp -d) && \
	./test/kfp-functional-test/kfp-functional-test.sh > $$log_dir/periodic_tests.txt

.PHONY: test-presubmit-backend
test-presubmit-backend:
	./test/presubmit-backend-test.sh

.PHONY: test-sdk-component-yaml
test-sdk-component-yaml:
	source .venv/bin/activate && \
	./test/presubmit-component-yaml.sh

.PHONY: test-sdk-docformatter
test-sdk-docformatter:
	source .venv/bin/activate && \
	./test/presubmit-docformatter-sdk.sh

.PHONY: test-sdk-execution
test-sdk-execution:
	source .venv/bin/activate && \
	./.github/resources/scripts/forward-port.sh "kubeflow" "ml-pipeline" 8888 8888 && \
	export KFP_ENDPOINT="http://localhost:8888" && \
	export TIMEOUT_SECONDS=2700 && \
	pytest ./test/sdk-execution-tests/sdk_execution_tests.py --asyncio-task-timeout $$TIMEOUT_SECONDS

.PHONY: test-sdk-isort
test-sdk-isort:
	source .venv/bin/activate && \
	./test/presubmit-isort-sdk.sh

.PHONY: test-sdk-upgrade
test-sdk-upgrade:
	source .venv/bin/activate && \
	./test/presubmit-test-sdk-upgrade.sh

.PHONY: test-sdk-yapf
test-sdk-yapf:
	source .venv/bin/activate && \
	./test/presubmit-yapf-sdk.sh
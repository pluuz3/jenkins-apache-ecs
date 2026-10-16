pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = 'apache-ecs'
        CONTAINER_NAME = 'apache-ecs-test'
        TEST_PORT = '8081'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        stage('Validate Files') {
            steps {
                sh '''
                    set -eu
                    test -f Dockerfile
                    test -f website/index.html
                    test -f scripts/healthcheck.sh
                    echo "Required project files exist."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                      -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    set -eu

                    docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true

                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p ${TEST_PORT}:80 \
                      ${IMAGE_NAME}:${BUILD_NUMBER}

                    trap 'docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true' EXIT

                    for i in $(seq 1 15); do
                        if curl -fsS http://127.0.0.1:${TEST_PORT}/ \
                            -o /tmp/apache-test.html; then
                            break
                        fi
                        sleep 2
                    done

                    grep -q 'Jenkins Apache ECS Project' /tmp/apache-test.html
                    echo "Apache HTTP smoke test passed."
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
            '''
            echo 'Pipeline completed. Review the build result above.'
        }

        success {
            echo 'SUCCESS: Apache image built and smoke test passed.'
        }

        failure {
            echo 'FAILURE: Check the stage logs to troubleshoot.'
        }
    }
}

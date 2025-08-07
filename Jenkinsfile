pipeline {
    agent any

    environment {
        IMAGE_NAME = "abhiwable4/cw2-server"
        IMAGE_TAG = "1.0"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/abhi1o1/devops-cw2.git',
                    credentialsId: 'github-token_CW2'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh """
                        docker rm -f test-container || true
                        docker run -d --name test-container -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 10
                        docker ps | grep test-container
                        docker stop test-container
                        docker rm test-container
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u abhiwable4 --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        docker pull bitnami/kubectl:latest

                        docker run --rm \
                            -v \$HOME/.kube:/root/.kube \
                            -v \$(pwd):/app \
                            -w /app \
                            bitnami/kubectl:latest \
                            kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker image prune -f'
        }
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}

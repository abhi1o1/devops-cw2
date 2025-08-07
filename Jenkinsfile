pipeline {
    agent any

    environment {
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh """
                        docker rm -f test-container || true
                        docker run -d --name test-container -p 8081:8081 ${env.IMAGE_NAME}:${env.IMAGE_TAG}
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
                withCredentials([string(credentialsId: 'dockerhub-password-id', variable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u abhiwable4 --password-stdin
                        docker push ${env.IMAGE_NAME}:${env.IMAGE_TAG}
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
                            -v \$WORKSPACE:/workspace \
                            -v /var/lib/jenkins/.kube:/root/.kube \
                            bitnami/kubectl:latest apply -f /workspace/k8s/deployment.yaml
                    """
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up Docker images..."
            sh 'docker image prune -f'
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
    }
}

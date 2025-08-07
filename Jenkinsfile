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
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh '''
                        docker rm -f test-container || true
                        docker run -d --name test-container -p 8081:8081 $IMAGE_NAME:$IMAGE_TAG
                        sleep 10
                        docker ps | grep test-container
                        docker stop test-container
                        docker rm test-container
                    '''
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                        # Pull the kubectl image
                        docker pull bitnami/kubectl:latest
                        # Run kubectl apply mounting kubeconfig and workspace
                        docker run --rm \
                            -v $WORKSPACE/k8s:/workspace/k8s \
                            -v /var/lib/jenkins/.kube:/root/.kube \
                            bitnami/kubectl:latest apply -f /workspace/k8s/deployment.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up Docker images...'
            sh 'docker image prune -f || true'
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
    }
}

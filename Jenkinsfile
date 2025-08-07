pipeline {
    agent any

    environment {
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
        DOCKER_CREDENTIALS_ID = 'dockerhub-login'        // Make sure this matches Jenkins credentials ID
        GITHUB_CREDENTIALS_ID = 'github-token_CW2'       // Already set correctly
        KUBECONFIG = '/home/ubuntu/.kube/config'         // Path to kubeconfig on production server
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/abhi1o1/devops-cw2.git',
                    branch: 'main',
                    credentialsId: "${GITHUB_CREDENTIALS_ID}"
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
                    sh 'docker rm -f test-container || true'
                    sh 'docker run -d --name test-container -p 8081:8081 $IMAGE_NAME:$IMAGE_TAG'
                    sh 'sleep 10'
                    sh 'docker ps | grep test-container'
                    sh 'docker stop test-container'
                    sh 'docker rm test-container'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl config use-context minikube
                    kubectl set image deployment/cw2-deployment cw2-container=$IMAGE_NAME:$IMAGE_TAG --record || kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/cw2-deployment
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
        always {
            echo 'Cleaning up...'
            sh 'docker image prune -f'
        }
    }
}

pipeline {
    agent any

    environment {
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
        DOCKER_CREDENTIALS_ID = 'dockerhub-login'      // Your Jenkins DockerHub credentials ID
        GITHUB_CREDENTIALS_ID = 'github-token_CW2'     // Your GitHub token credentials ID
        KUBECONFIG = '/home/ubuntu/.kube/config'       // Path on the production server
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
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh """
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent (credentials: ['production-server-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@98.86.205.139 << EOF
                            kubectl set image deployment/cw2-deployment cw2-server=$IMAGE_NAME:$IMAGE_TAG --kubeconfig=$KUBECONFIG
                            kubectl rollout status deployment/cw2-deployment --kubeconfig=$KUBECONFIG
                        EOF
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
            echo '✅ Pipeline completed successfully!'
        }

        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}

pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "abhiwable4/cw2-server"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        PRODUCTION_SERVER = "98.86.205.139"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    credentialsId: 'github-token_CW2', 
                    url: 'https://github.com/abhi1o1/devops-cw2.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
            }
        }
        
        stage('Test Container') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh """
                        docker rm -f test-container || true
                        docker run -d --name test-container -p 8081:8081 ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        sleep 10
                        docker ps | grep test-container
                        docker stop test-container
                        docker rm test-container
                    """
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-password', variable: 'DH_PASS')]) {
                    sh """
                        docker logout
                        echo \$DH_PASS | docker login -u abhiwable4 --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'production-server-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        echo "Testing SSH connection..."
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${PRODUCTION_SERVER} 'echo "SSH connection successful"'
                        
                        echo "Deploying to Kubernetes..."
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${PRODUCTION_SERVER} '
                            echo "Current deployments:"
                            kubectl get deployments
                            
                            echo "Updating deployment with new image..."
                            kubectl set image deployment/cw2-server-deployment cw2-server=${DOCKER_IMAGE}:${BUILD_NUMBER}
                            
                            echo "Waiting for rollout to complete..."
                            kubectl rollout status deployment/cw2-server-deployment --timeout=300s
                            
                            echo "Current pods status:"
                            kubectl get pods
                            
                            echo "Service information:"
                            kubectl get services
                        '
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'production-server-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        echo "Verifying application is running..."
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@${PRODUCTION_SERVER} '
                            MINIKUBE_IP=\$(minikube ip)
                            SERVICE_PORT=\$(kubectl get service cw2-server-service -o jsonpath="{.spec.ports[0].nodePort}")
                            echo "Application should be accessible at: \$MINIKUBE_IP:\$SERVICE_PORT"
                            curl -m 10 \$MINIKUBE_IP:\$SERVICE_PORT || echo "Application might still be starting..."
                        '
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo "Build #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"
        }
        success {
            echo "Pipeline completed successfully! New version deployed."
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}

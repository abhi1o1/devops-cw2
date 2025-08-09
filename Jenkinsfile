pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "abhiwable4/cw2-server:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Test Container') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh '''
                        docker rm -f test-container || true
                        docker run -d --name test-container -p 8081:8081 ${DOCKER_IMAGE}
                        sleep 10
                        docker ps | grep test-container
                        docker stop test-container
                        docker rm test-container
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-password-id', variable: 'DOCKER_HUB_PASSWORD')]) {
                    sh '''
                        echo "$DOCKER_HUB_PASSWORD" | docker login -u abhiwable4 --password-stdin
                        docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: '3eecce0d-0c4b-40d4-be0d-6febab5bc0fe',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                        echo "Running Ansible Playbook for Kubernetes Deployment..."
                        ansible-playbook ansible/deploy_k8s.yml -i ansible/hosts --private-key $SSH_KEY -u ubuntu
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Build #${BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"
        }
    }
}

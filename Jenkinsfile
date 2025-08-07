pipeline {
    agent any

    environment {
        IMAGE_NAME = "cw2-app"
        IMAGE_TAG = "v1"
        IMAGE_TAR = "cw2-app.tar"
        PROD_SERVER = "ubuntu@PRODUCTION_SERVER_IP_OR_HOSTNAME"  // Replace with your production server IP or hostname
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Save Docker Image') {
            steps {
                sh "docker save -o ${IMAGE_TAR} ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Copy Image to Production Server') {
            steps {
                sshagent(['prod-ssh-key']) {  // This is the SSH credentials ID in Jenkins for your production server
                    sh "scp -o StrictHostKeyChecking=no ${IMAGE_TAR} ${PROD_SERVER}:~/"
                }
            }
        }

        stage('Deploy on Production Server') {
            steps {
                sshagent(['prod-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${PROD_SERVER} << EOF
                        docker load -i ~/${IMAGE_TAR}
                        ansible-playbook ~/k8s_deploy.yml -i ~/hosts
                    EOF
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Build or Deployment failed!"
        }
        success {
            echo "Build and Deployment succeeded!"
        }
    }
}

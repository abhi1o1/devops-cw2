pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhiwable4/cw2-server:1.0'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/abhi1o1/devops-cw2.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh """
                        docker run -d --name test-container -p 8081:8081 ${DOCKER_IMAGE}
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        sh """
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            docker push ${DOCKER_IMAGE}
                            docker logout
                        """
                    }
                }
            }
        }
    }
}

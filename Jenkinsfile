pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-password-id')
        IMAGE_NAME = "abhiwable4/cw2-server"
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/abhi1o1/devops-cw2.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
            }
        }

        stage('Test Container') {
            steps {
                sh "docker run -d --rm -p 8081:8081 --name test-container $IMAGE_NAME:$IMAGE_TAG"
                sh "sleep 5" // Wait for container to start
                sh "docker exec test-container curl -s http://localhost:8081"
                sh "docker stop test-container"
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                sh "docker push $IMAGE_NAME:$IMAGE_TAG"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl set image deployment/cw2-server cw2-container=$IMAGE_NAME:$IMAGE_TAG --record
                """
            }
        }
    }
}

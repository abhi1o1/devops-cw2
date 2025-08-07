pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhiwable4/cw2-server:1.0'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-password-id')
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
                    sh 'docker build -t $DOCKER_IMAGE .'
                }
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh 'docker run -d --name test-container -p 8081:8081 $DOCKER_IMAGE'
                    sh 'sleep 10'
                    sh 'docker ps | grep test-container'
                    sh 'docker stop test-container'
                    sh 'docker rm test-container'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl set image deployment/cw2-server cw2-container=$DOCKER_IMAGE'
                }
            }
        }
    }
}

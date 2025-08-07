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
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh 'docker rm -f test-container || true'
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                        docker push $DOCKER_IMAGE
                        docker logout
                    '''
                }
            }
        }
    }
}

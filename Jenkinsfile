pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'abhiwable4'
        DOCKER_HUB_PASS = credentials('dockerhub-password-id')
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                    // Run container detached
                    sh "docker run -d --name cw2-test -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}"
                    sleep 5
                    sh "docker ps | grep cw2-test"
                    sh "docker rm -f cw2-test"
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    sh "echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl set image deployment/cw2-deployment cw2-container=${IMAGE_NAME}:${IMAGE_TAG} --record"
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
        success {
            echo 'Pipeline finished successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

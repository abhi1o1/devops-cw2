pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'abhiwable4/cw2-server:1.0'
        DOCKER_CREDENTIALS = credentials('dockerhub-password-id')
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
                    // Clean up any existing container
                    sh 'docker rm -f test-container || true'
                    
                    // Run container for testing
                    sh 'docker run -d --name test-container -p 8081:8081 $DOCKER_IMAGE'
                    
                    // Wait for container to start
                    sh 'sleep 10'
                    
                    // Check container status
                    sh 'docker ps | grep test-container'
                    
                    // Stop and remove container after testing
                    sh 'docker stop test-container'
                    sh 'docker rm test-container'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    // Login and push to Docker Hub
                    sh '''
                        echo "$DOCKER_CREDENTIALS_PSW" | docker login -u "$DOCKER_CREDENTIALS_USR" --password-stdin
                        docker push $DOCKER_IMAGE
                        docker logout
                    '''
                }
            }
        }
    }
}

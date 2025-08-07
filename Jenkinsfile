pipeline {
    agent any

    environment {
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main', credentialsId: 'github-token_CW2'
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
                    // Clean up old container if exists
                    sh 'docker rm -f test-container || true'
                    
                    // Run container in detached mode
                    sh 'docker run -d --name test-container -p 8081:8081 $IMAGE_NAME:$IMAGE_TAG'
                    
                    // Wait for the container to start
                    sh 'sleep 10'

                    // Confirm it’s running
                    sh 'docker ps | grep test-container'

                    // Stop and remove container after testing
                    sh 'docker stop test-container'
                    sh 'docker rm test-container'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up dangling Docker resources...'
            sh 'docker image prune -f || true'
        }
        failure {
            echo 'Pipeline failed.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}

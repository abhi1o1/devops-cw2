pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-password-id')
        GITHUB_CREDENTIALS = credentials('github-token_CW2')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/abhi1o1/devops-cw2.git',
                        credentialsId: "${GITHUB_CREDENTIALS}"
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "abhiwable4/cw2-server:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                    env.IMAGE_TAG = imageTag
                }
            }
        }

        stage('Test Container') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "docker rm -f test-container || true"
                        sh "docker run -d --name test-container -p 8081:8081 ${env.IMAGE_TAG}"
                        sleep 10
                        sh "docker exec test-container curl -f http://localhost:8081"
                        sh "docker stop test-container"
                        sh "docker rm test-container"
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Change deploy_k8s.yml to your actual k8s manifest file
                    sh 'kubectl apply -f deploy_k8s.yml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verify deployment steps here...'
                // You can add kubectl get pods, logs, etc. as needed
            }
        }
    }

    post {
        always {
            echo 'Cleaning up unused Docker images'
            sh 'docker image prune -f'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}

kpipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials-id')  // Update with your Jenkins Docker Hub credentials ID
        GITHUB_CREDENTIALS = credentials('github-credentials-id')         // Update with your Jenkins GitHub credentials ID
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
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
                }
            }
        }

        stage('Test Container') {
            steps {
                script {
                    def imageTag = "abhiwable4/cw2-server:${env.BUILD_NUMBER}"
                    catchError {
                        sh "docker rm -f test-container || true"
                        sh "docker run -d --name test-container -p 8081:8081 ${imageTag}"
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
                    def imageTag = "abhiwable4/cw2-server:${env.BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${imageTag}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Updated path to ansible folder
                    sh 'kubectl apply -f ansible/deploy_k8s.yml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Skipping due to deploy step failure or can add verification commands here."
                }
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
    }
}


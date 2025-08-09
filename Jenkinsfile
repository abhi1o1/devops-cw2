kpipeline {
    agent any

    environment {
        DOCKER_IMAGE = "abhiwable4/cw2-server"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/abhi1o1/devops-cw2.git',
                        credentialsId: 'github-token_CW2'
                    ]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Test Container') {
            steps {
                script {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh "docker rm -f test-container || true"
                        sh "docker run -d --name test-container -p 8081:8081 ${DOCKER_IMAGE}:${DOCKER_TAG}"
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('List Ansible Folder') {
            steps {
                sh 'ls -la ansible/'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Apply the k8s manifest inside ansible folder
                    sh 'kubectl apply -f ansible/deploy_k8s.yml'
                    // If you want to use k8s_deploy.yml, replace above line accordingly
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                // Example: check pods running, or your own verification
                sh 'kubectl get pods'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up unused Docker images...'
            sh 'docker image prune -f || true'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}


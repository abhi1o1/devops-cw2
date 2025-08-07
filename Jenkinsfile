pipeline {
    agent any

    environment {
        // Removed DOCKER_USER here; will come from credentials
        KUBECONFIG = '/home/ubuntu/.kube/config'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM', 
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
                sh 'docker build -t abhiwable4/cw2-server:1.0 .'
            }
        }

        stage('Test Container') {
            steps {
                script {
                    sh 'docker rm -f test-container || true'
                    sh 'docker run -d --name test-container -p 8081:8081 abhiwable4/cw2-server:1.0'
                    sh 'sleep 10'
                    sh 'docker ps | grep test-container'
                    sh 'docker stop test-container'
                    sh 'docker rm test-container'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-password-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push abhiwable4/cw2-server:1.0
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Using official kubectl image to avoid "kubectl: not found"
                script {
                    docker.image('bitnami/kubectl:latest').inside {
                        sh "kubectl --kubeconfig=${env.KUBECONFIG} apply -f k8s/deployment.yaml"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker image prune -f'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}

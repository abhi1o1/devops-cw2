pipeline {
    agent any

    environment {
        DOCKER_USER = 'abhiwable4'
        DOCKER_PASS = credentials('dockerhub-password-id')  // your updated DockerHub password credential ID
        KUBECONFIG = '/home/ubuntu/.kube/config'             // path to your kubeconfig file
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Checkout') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
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
                withCredentials([string(credentialsId: 'dockerhub-password-id', variable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push abhiwable4/cw2-server:1.0
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
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


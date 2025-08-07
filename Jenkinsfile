pipeline {
    agent any

    environment {
        IMAGE_NAME = 'abhiwable4/cw2-server'
        IMAGE_TAG = '1.0'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Test Container') {
            steps {
                script {
                    // Stop and remove old test container if it exists
                    sh 'docker rm -f test-container || true'
                    // Run container in background
                    sh 'docker run -d --name test-container -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}'
                    // Wait for app to start
                    sh 'sleep 10'
                    // Confirm it's running
                    sh 'docker ps | grep test-container'
                    // Stop and clean up
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
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Optional: update your kubeconfig if not already done
                    // sh 'mkdir -p ~/.kube && cp /path/to/kubeconfig ~/.kube/config'

                    sh '''
                        docker pull bitnami/kubectl:latest
                        docker run --rm \
                            -v $PWD:/workspace \
                            -v ~/.kube:/root/.kube \
                            bitnami/kubectl:latest \
                            kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }

    post {

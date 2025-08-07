pipeline {
    agent any

    environment {
        IMAGE_NAME = "cw2-app"
        IMAGE_TAG = "v1"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-token_CW2', url: 'https://github.com/abhi1o1/devops-cw2.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Save Docker Image to Tar') {
            steps {
                sh 'docker save -o cw2-app.tar $IMAGE_NAME:$IMAGE_TAG'
            }
        }

        stage('Copy Image to Minikube') {
            steps {
                sh 'minikube image load cw2-app.tar'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s_deploy.yml'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods'
                sh 'kubectl get svc'
            }
        }
    }

    post {
        failure {
            echo "Build failed!"
        }
        success {
            echo "Deployment successful!"
        }
    }
}

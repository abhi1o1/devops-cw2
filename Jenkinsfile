pipeline {
  agent any
  environment {
    IMAGE_NAME = 'abhiwable4/cw2-server'
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
    FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
  }
  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'github-token_CW2',
            url: 'https://github.com/abhi1o1/devops-cw2.git',
            branch: 'main'
      }
    }
    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${FULL_IMAGE} ."
      }
    }
    stage('Test Container') {
      steps {
        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
          sh '''
            docker rm -f test-container || true
            docker run -d --name test-container -p 8081:8081 ${FULL_IMAGE}
            sleep 10
            docker ps | grep test-container
            docker stop test-container
            docker rm test-container
          '''
        }
      }
    }
    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-password-id',
          usernameVariable: 'DH_USER',
          passwordVariable: 'DH_PASS'
        )]) {
          sh '''
            docker logout || true
            echo $DH_PASS | docker login -u $DH_USER --password-stdin
            docker push ${FULL_IMAGE}
          '''
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([sshUserPrivateKey(
          credentialsId: 'SSH_KEY',
          keyFileVariable: 'SSH_KEY',
          usernameVariable: 'SSH_USER'
        )]) {
          sh """
            echo "Testing SSH connection..."
            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@98.86.205.139 'echo "SSH connection successful"'
            
            echo "Deploying to Kubernetes..."
            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@98.86.205.139 '
              echo "Current deployments:"
              kubectl get deployments
              
              echo "Updating deployment with new image..."
              kubectl set image deployment/cw2-server-deployment cw2-server=${FULL_IMAGE}
              
              echo "Waiting for rollout to complete..."
              kubectl rollout status deployment/cw2-server-deployment --timeout=300s
              
              echo "Current pods status:"
              kubectl get pods
              
              echo "Service information:"
              kubectl get services
              
              echo "Verifying application is accessible..."
              MINIKUBE_IP=\$(minikube ip)
              SERVICE_PORT=\$(kubectl get service cw2-server-service -o jsonpath="{.spec.ports[0].nodePort}")
              echo "Application accessible at: \$MINIKUBE_IP:\$SERVICE_PORT"
              curl -m 10 \$MINIKUBE_IP:\$SERVICE_PORT || echo "Application might still be starting up..."
            '
          """
        }
      }
    }
  }
  post {
    always {
      echo "Build #${env.BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"
    }
    success {
      echo "Pipeline completed successfully! New version ${IMAGE_TAG} deployed."
    }
    failure {
      echo "Pipeline failed. Check logs for details."
    }
  }
}

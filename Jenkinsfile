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
    stage('Deploy to Kubernetes with Ansible') {
      steps {
        sh """
          echo "Starting Kubernetes deployment with Ansible..."
          
          # Check if SSH key exists and has correct permissions
          ls -la /var/lib/jenkins/Key_Pair_Lab5.pem
          
          # Test SSH connection first
          ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/Key_Pair_Lab5.pem ubuntu@98.86.205.139 'echo "SSH connection successful"'
          
          # Run Ansible playbook for Kubernetes deployment
          ansible-playbook ansible/deploy_k8s.yml -i ansible/hosts \\
            --private-key /var/lib/jenkins/Key_Pair_Lab5.pem -u ubuntu \\
            --extra-vars 'image_tag=${IMAGE_TAG}' -v
            
          echo "Deployment completed successfully!"
        """
      }
    }
    stage('Verify Deployment') {
      steps {
        sh """
          echo "Verifying deployment..."
          ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/Key_Pair_Lab5.pem ubuntu@98.86.205.139 '
            echo "Current deployments:"
            kubectl get deployments
            
            echo "Current pods:"
            kubectl get pods
            
            echo "Service information:"
            kubectl get services
            
            echo "Checking application accessibility:"
            MINIKUBE_IP=\$(minikube ip)
            SERVICE_PORT=\$(kubectl get service cw2-server-service -o jsonpath="{.spec.ports[0].nodePort}" 2>/dev/null || echo "30000")
            echo "Application should be accessible at: \$MINIKUBE_IP:\$SERVICE_PORT"
            curl -m 10 \$MINIKUBE_IP:\$SERVICE_PORT || echo "Application might still be starting up..."
          '
        """
      }
    }
  }
  post {
    always {
      echo "Build #${env.BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"
    }
    success {
      echo "Pipeline completed successfully! New version ${IMAGE_TAG} deployed to Kubernetes."
    }
    failure {
      echo "Pipeline failed. Check logs above for details."
    }
  }
}

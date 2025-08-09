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
            # Simple curl test inside container
            docker exec test-container curl -f http://localhost:8081
            docker stop test-container
            docker rm test-container
          '''
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker push ${FULL_IMAGE}
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh """
          kubectl set image deployment/cw2-server cw2-server=${FULL_IMAGE} --record
        """
      }
    }

    stage('Verify Deployment') {
      steps {
        sh """
          kubectl rollout status deployment/cw2-server
          kubectl get pods
        """
      }
    }
  }
  post {
    always {
      echo 'Cleaning up unused Docker images'
      sh "docker image prune -f"
    }
  }
}

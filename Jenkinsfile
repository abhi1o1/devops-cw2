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

    stage('Verify Workspace') {
      steps {
        sh 'echo "Workspace Contents:" && ls -R $WORKSPACE'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${FULL_IMAGE} ."
      }
    }

    stage('Test Container') {
      steps {
        script {
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
            echo $DH_PASS | docker login -u $DH_USER --password-stdin
            docker push ${FULL_IMAGE}
          '''
        }
      }
    }

    stage('Install Kubernetes Tools') {
      steps {
        ansiblePlaybook(
          playbook: 'ansible/deploy_k8s.yml',
          inventory: 'ansible/hosts',
          installation: 'ansible',
          credentialsId: 'ssh-prod-cred',
          colorized: true,
          hostKeyChecking: false,          // Disables SSH host key check for this step
          disableHostKeyChecking: true     // Plugin-level override
        )
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        ansiblePlaybook(
          playbook: 'ansible/k8s_deploy.yml',
          inventory: 'ansible/hosts',
          installation: 'ansible',
          credentialsId: 'ssh-prod-cred',
          colorized: true,
          hostKeyChecking: false,           // Disables SSH host key check
          disableHostKeyChecking: true,     // Plugin-level override
          extraVars: [ image_tag: "${IMAGE_TAG}" ]
        )
      }
    }
  }

  post {
    always {
      echo "Build #${env.BUILD_NUMBER} finished at ${new Date()} with status: ${currentBuild.currentResult}"
    }
  }
}

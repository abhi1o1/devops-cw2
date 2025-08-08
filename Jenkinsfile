pipeline {
  agent any

  environment {
    IMAGE_NAME = 'abhiwable4/cw2-server'
    IMAGE_TAG  = "${env.BUILD_NUMBER}"        // Dynamic tag using Jenkins build number
    FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
  }

  stages {
    stage('Checkout SCM') {
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
        script {
          sh """
            docker rm -f test-container || true
            docker run -d --name test-container -p 8081:8081 ${FULL_IMAGE}
            sleep 10
            docker ps | grep test-container
            docker stop test-container
            docker rm test-container
          """
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
          sh """
            echo $DH_PASS | docker login -u $DH_USER --password-stdin
            docker push ${FULL_IMAGE}
          """
        }
      }
    }

    stage('Deploy via Ansible') {
      steps {
        ansiblePlaybook(
          installation: 'ansible',           // Configured in Manage Jenkins → Global Tool Configuration
          inventory: 'hosts',                // Inventory file in your repo
          playbook: 'deploy.yml',            // Your Ansible playbook
          credentialsId: 'ssh-prod-cred',    // SSH key credential for your production server
          colorized: true,
          extraVars: [
            [key: 'image_tag', secretValue: env.IMAGE_TAG]
          ]
        )
      }
    }
  }

  post {
    always {
      echo "Build ${env.BUILD_NUMBER} completed at ${new Date()}"
    }
  }
}

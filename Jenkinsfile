pipeline {
    environment { 
        registryCredential = 'docker-hub-credentials'
    }
  agent any
  stages {
    stage('Build result') {
      steps {
        script{
            dockerImage = docker.build("milelucero98/result:${env.BUILD_ID}", "-t ${dockerfile} ./result")
        }
      }
    } 
    
    stage('Deploy image') { 
        steps {
            script {
                docker.withRegistry('', registryCredential) { 
                dockerImage.push() 
                }
            } 
        }
    }
    
    stage('Build vote') {
      steps {
        sh 'docker build -t milelucero98/vote:latest ./vote'
      }
    }
    
    stage('Deploy image') { 
        steps {
            script {
                docker.withRegistry('', registryCredential ) { 
                dockerImage.push() 
                }
            } 
        }
    }
    
    stage('Build worker') {
      steps {
        sh 'docker build -t milelucero98/worker:latest ./worker'
      }
    }
    
    stage('Deploy image') { 
        steps {
            script {
                docker.withRegistry( '', registryCredential ) { 
                dockerImage.push() 
                }
            } 
        }
    } 
    
    

  }
}

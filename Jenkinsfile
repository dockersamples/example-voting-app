pipeline {
    environment { 
        registry = "milelucero98/tp-integrador" 
        registryCredential = 'docker-hub-credentials'
        dockerImageResult = 'dockersamples/result' 
        dockerImageVote = 'dockersamples/vote'
        dockerImageWorker = 'dockersamples/worker'
    }
  agent any
  stages {
    stage('Build result') {
      steps {
        sh 'docker build -t dockersamples/result ./result'
      }
    } 
    stage('Deploy result') { 
        steps {
            script {
                docker.withRegistry( '', registryCredential ) { 
                dockerImageResult.push() 
                }
            } 
        }
    } 
    stage('Build vote') {
      steps {
        sh 'docker build -t dockersamples/vote ./vote'
      }
    }
    stage('Deploy vote') { 
        steps {
            script {
                docker.withRegistry( '', registryCredential ) { 
                dockerImageVote.push() 
                }
            } 
        }
    } 
    stage('Build worker') {
      steps {
        sh 'docker build -t dockersamples/worker ./worker'
      }
    }
    stage('Deploy worker') { 
        steps {
            script {
                docker.withRegistry( '', registryCredential ) { 
                dockerImageWorker.push() 
                }
            } 
        }
    } 

  }
}

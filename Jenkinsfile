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
        script { 
            dockerImage = docker.build dockerImageResult + ":$BUILD_NUMBER" 
        }
      }
    }
    
    stage('Push result image') {
      steps {
        script { 
          docker.withRegistry( '', registryCredential ) { 
                dockerImage.push() 
            }
        }
      }
    }
    stage('Build vote') {
      steps {
        script { 
            dockerImage = docker.build dockerImageVote ./vote + ":$BUILD_NUMBER" 
            }
        }
    }
    stage('Push vote image') {
      steps {
        script { 
          docker.withRegistry( '', registryCredential ) { 
                dockerImage.push() 
                }
            }
        }
    }
    stage('Build worker') { 
      steps {
       script { 
            dockerImage = docker.build dockerImageWorker ./worker + ":$BUILD_NUMBER" 
        }
      }
    }
     stage('Push worker image') {
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

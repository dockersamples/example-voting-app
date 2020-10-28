pipeline {
    environment { 
        registry = "milelucero98/tp-integrador" 
        registryCredential = 'docker-hub-credentials'
        dockerImage = '' 
     }
  agent any
  stages {
    stage('Build result') {
      steps {
        script { 
            dockerImage = docker.build dockersamples/result + ":$BUILD_NUMBER" 
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
            dockerImage = docker.build dockersamples/vote ./vote + ":$BUILD_NUMBER" 
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
            dockerImage = docker.build dockersamples/worker ./worker + ":$BUILD_NUMBER" 
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

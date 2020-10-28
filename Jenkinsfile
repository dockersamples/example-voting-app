pipeline {
    environment { 
        registryCredential = 'docker-hub-credentials'
        dockerImage = '' 
    }
  agent any
  stages {
    stage('Build result') {
      steps {
        sh 'docker build -t dockersamples/result ./result'
      }
    } 
    stage('Build vote') {
      steps {
        sh 'docker build -t dockersamples/vote ./vote'
      }
    }
    stage('Build worker') {
      steps {
        sh 'docker build -t dockersamples/worker ./worker'
      }
    }
    stage('Push result image') {
      steps {
        withDockerRegistry(credentialsId: registryCredential, url:'https://hub.docker.com/repository/docker/milelucero98/tp-integrador') {
          sh 'docker push dockersamples/result'
        }
      }
    }
    stage('Push vote image') {
      steps {
        withDockerRegistry(credentialsId: registryCredential, url:'https://hub.docker.com/repository/docker/milelucero98/tp-integrador') {
          sh 'docker push dockersamples/vote'
        }
      }
    }
    stage('Push worker image') {
      steps {
        withDockerRegistry(credentialsId: registryCredential, url:'https://hub.docker.com/repository/docker/milelucero98/tp-integrador') {
          sh 'docker push dockersamples/worker'
        }
      }
    }
  }
}

pipeline {
    environment { 
        registry = "YourDockerhubAccount/YourRepository" 
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
        withDockerRegistry(credentialsId: registryCredential, url:'') {
          sh 'docker push dockersamples/result'
        }
      }
    }
    stage('Push vote image') {
      steps {
        withDockerRegistry(credentialsId: registryCredential, url:'') {
          sh 'docker push dockersamples/vote'
        }
      }
    }
    stage('Push worker image') {
      steps {
        withDockerRegistry(credentialsId: registryCredential, url:'') {
          sh 'docker push dockersamples/worker'
        }
      }
    }
  }
}

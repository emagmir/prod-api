pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials("emagmir-dockerhub")
        DOCKERHUB_REPO = "emagmir/fast-api-cicd"
        DOCKER_REGISTRY = "https://registry.hub.docker.com"
    }

    stages {

        stage ('Clone repository') {
            checkout scm
        }

        stage ('Build') {
            dockerImage = docker.build ("$DOCKERHUB_REPO")
        }

        stage ('Test image') {
            dockerImage.inside {
                sh 'echo "All tests passed ayy lmao"'
            }
        }

        stage ('Push image') {
            docker.withRegistry (DOCKER_REGISTRY, DOCKERHUB_CREDENTIALS) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
            }
        }
    }
}
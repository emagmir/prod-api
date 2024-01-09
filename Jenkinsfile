pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "emagmir/fast-api-cicd"
        DOCKER_REGISTRY = "https://registry.hub.docker.com"
    }

    stages {

        stage ('Clone repository') {
            steps {
                checkout scm
            }
        }

        stage ('Build') {
            steps {
                script {
                    sh 'echo $USER'
                    dockerImage = docker.build("$DOCKERHUB_REPO")
                }
            }
        }

        stage ('Test image') {
            steps {
                script {
                    dockerImage.inside {
                        sh 'echo "All tests passed ayy lmao"'
                    }
                }
            }
        }

        stage ('Push image') {
            steps {
                script {
                    docker.withRegistry(DOCKER_REGISTRY, 'emagmir-dockerhub') {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
    }
}
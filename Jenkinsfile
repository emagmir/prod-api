pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "emagmir/fast-api-cicd"
        DOCKER_REGISTRY = "https://registry.hub.docker.com"
        KUBERNETES_FOLDER = 'kubernetes'
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

        stage ('Deploy to k8s cluster') {
            steps {
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'dep_k8s', contextName: '', credentialsId: 'SECRET_TOKEN', namespace: 'default', serverUrl: 'https://192.168.56.3:6443']]) {
                    script {
                        def kubernetesDir = '/kubernetes'
                        sh "kubectl apply -f $KUBERNETES_FOLDER/*.yaml"
                    }
                }
            }
        }
    }
}
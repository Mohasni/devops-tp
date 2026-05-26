pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'mohasni'
        IMAGE_NAME      = 'mon-app-js'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Utilise l'ID des identifiants que l'on va créer à l'étape suivante
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Modifie le fichier deployment.yaml pour y mettre ton image Docker Hub et l'appliquer
                sh "sed -i 's|IMAGE_PLACEHOLDER|${DOCKER_HUB_USER}/${IMAGE_NAME}:latest|g' deployment.yaml"
                sh "kubectl apply -f deployment.yaml"
                sh "kubectl apply -f service.yaml"
            }
        }
    }

    post {
        success {
            echo "Pipeline Réussi ! Simulation d'envoi d'email de succès."
        }
        failure {
            echo "Pipeline Échoué ! Simulation d'envoi d'email d'échec."
        }
    }
}
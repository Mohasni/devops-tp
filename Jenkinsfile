pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'mon-app-js'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_REGISTRY = 'docker.io'
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Récupération du code source...'
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                echo 'Installation des dépendances npm...'
                sh 'npm install'
            }
        }

        stage('Tests') {
            steps {
                echo 'Exécution des tests...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Création de l\'image Docker...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Push de l\'image vers Docker Hub...'
                sh """
                    echo ${DOCKER_CREDENTIALS} | docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin ${DOCKER_REGISTRY}
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_CREDENTIALS_USR}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker tag ${DOCKER_IMAGE}:latest ${DOCKER_CREDENTIALS_USR}/${DOCKER_IMAGE}:latest
                    docker push ${DOCKER_CREDENTIALS_USR}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_CREDENTIALS_USR}/${DOCKER_IMAGE}:latest
                    docker logout ${DOCKER_REGISTRY}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Déploiement sur Kubernetes...'
                sh """
                    # Appliquer les fichiers de déploiement Kubernetes
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    # Attendre que les pods soient prêts
                    kubectl rollout status deployment/${DOCKER_IMAGE}
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Vérification du déploiement...'
                sh """
                    kubectl get pods
                    kubectl get services
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès !'
            emailext(
                subject: "SUCCESS: Pipeline Jenkins - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Le pipeline CI/CD s'est terminé avec succès.

                    Détails:
                    - Projet: ${env.JOB_NAME}
                    - Build: #${env.BUILD_NUMBER}
                    - Image Docker: ${DOCKER_IMAGE}:${DOCKER_TAG}
                    - Commit: ${env.GIT_COMMIT}
                """,
                to: 'equipe-dev@example.com'
            )
        }
        failure {
            echo 'Pipeline échoué !'
            emailext(
                subject: "FAILURE: Pipeline Jenkins - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Le pipeline CI/CD a échoué.

                    Détails:
                    - Projet: ${env.JOB_NAME}
                    - Build: #${env.BUILD_NUMBER}
                    - Commit: ${env.GIT_COMMIT}
                """,
                to: 'equipe-dev@example.com'
            )
        }
    }
}
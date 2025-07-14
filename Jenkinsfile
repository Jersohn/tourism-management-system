pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = 'VOTRE_ID_COMPTE'
        AWS_REGION = 'eu-west-1'
        ECR_REPO = 'votre-projet-php'
        DOCKER_IMAGE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${env.BUILD_ID}"
        PHP_VERSION = '5.6' // Explicitement déclaré pour contrôle
    }

    stages {
        stage('Checkout GitHub') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/Jersohn/tourism-management-system.git',
                    credentialsId: 'github-creds' // Credentials Jenkins pour accès privé
                )
            }
        }

        stage('Verify PHP Compatibility') {
            steps {
                sh """
                # Vérification rapide de la compatibilité PHP 5.6
                find . -name '*.php' -type f -exec php -l {} \; | grep -v "No syntax errors"
                """
            }
        }

        stage('Build Docker Image (PHP 5.6)') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE, "--build-arg PHP_VERSION=${PHP_VERSION} .")
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'aws-creds', region: AWS_REGION) {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com") {
                        docker.image(DOCKER_IMAGE).push()
                        // Taggage supplémentaire en 'latest' si nécessaire
                        docker.image(DOCKER_IMAGE).push('latest')
                    }
                }
            }
        }

        stage('Deploy to ECS/Fargate') {
            steps {
                withAWS(credentials: 'aws-creds', region: AWS_REGION) {
                    sh """
                    aws ecs update-service \
                        --cluster votre-cluster \
                        --service votre-service \
                        --force-new-deployment \
                        --region ${AWS_REGION}
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Nettoyage de l'espace de travail
            script {
                // Suppression des images locales pour libérer de l'espace
                sh "docker rmi ${DOCKER_IMAGE} || true"
            }
        }
        failure {
            slackSend channel: '#jenkins-alerts',
                     message: "Échec du build ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
    }
}
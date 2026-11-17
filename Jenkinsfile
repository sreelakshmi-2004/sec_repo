
pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'sreelakshmins2004/aws-dashboard'
        SONAR_SERVER_NAME     = 'sonarqube-env'
        SONAR_SCANNER_TOOL    = 'sonar-scanner'
        GIT_CREDENTIALS_ID    = 'github-cred'
    }

    stages {

        // Stage 1: Checkout Source Code
        stage('Checkout Source Code') {
            steps {
                echo "Checking out AWS Dashboard source code..."
                checkout scm
            }
        }

        // Stage 2: SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"

                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=aws-dashboard \
                                -Dsonar.projectName='AWS Infrastructure Dashboard' \
                                -Dsonar.sources=. \
                                -Dsonar.exclusions=Jenkinsfile,Dockerfile,README.md,manifests/** \
                                -Dsonar.sourceEncoding=UTF-8
                        """
                    }
                }
            }
        }

        // Stage 3: File Verification
        stage('File Verification') {
            steps {
                echo "Verifying AWS Dashboard files..."

                sh '''
                    test -f index.html
                    test -f css/style.css
                    test -f Dockerfile
                '''

                echo "All required AWS Dashboard files are verified."
            }
        }

        // Stage 4: Build & Push Docker Image
        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS_ID}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

                            docker build \
                                -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} \
                                -t ${DOCKER_IMAGE}:latest \
                                -f ./Dockerfile .

                            docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest

                            docker logout
                        """
                    }
                }
            }
        }

        // Stage 5: Deploy to EC2
        stage('Deploy to EC2') {
            steps {
                script {
                    sh """
                        docker pull ${DOCKER_IMAGE}:${env.BUILD_NUMBER}

                        docker stop aws-dashboard || true
                        docker rm aws-dashboard || true

                        docker run -d \
                            --restart unless-stopped \
                            --name aws-dashboard \
                            -p 8071:80 \
                            ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully! AWS Dashboard deployed to EC2.'
        }

        failure {
            echo 'Pipeline failed. Please review the stage logs above.'
        }

        always {
            echo 'AWS Dashboard pipeline execution completed.'
        }
    }
}

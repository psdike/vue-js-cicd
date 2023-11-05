pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Vue.js Application') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    def imageName = "your-repo/your-app:${env.BUILD_NUMBER}"
                    docker.build(imageName, "-f Dockerfile .")
                    docker.withRegistry('https://your-docker-registry-url', 'your-registry-credentials-id') {
                        docker.image(imageName).push()
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                // Implement your deployment logic here, e.g., Kubernetes, Docker Swarm, AWS ECS, etc.
                // You can use kubectl, docker stack deploy, or AWS CLI for this.
            }
        }

        stage('Vulnerability Scan') {
            steps {
                script {
                    def imageName = "your-repo/your-app:${env.BUILD_NUMBER}"
                    try {
                        sh "trivy image $imageName"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Vulnerability scan failed: ${e.message}")
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts 'dist/**' // Archive build artifacts
            junit '**/test-results.xml' // Archive test results if available
        }
    }
}

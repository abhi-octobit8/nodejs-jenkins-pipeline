pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code from your version control system (e.g., Git)
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install Node.js and npm (if not already installed)
                bat 'nvm install 14'  // You may need to adjust the Node.js version
                bat 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                // Run your Node.js application's tests
                bat 'npm test'
            }
        }

        stage('Build and Package') {
            steps {
                // Your build and packaging steps if needed
                // For example, creating a production build
                bat 'npm run build'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube Server') {
                    sh """
                    npm install -g sonarqube-scanner
                    sonar-scanner \
                        -Dsonar.host.url=${env.SONARQUBE_URL} \
                        -Dsonar.login=${env.SONARQUBE_TOKEN} \
                        -Dsonar.projectKey=your-project-key \
                        -Dsonar.sources=. \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov-report/lcov.info
                    """
                }
            }
        }

        stage('Publish to Artifactory') {
            steps {
                script {
                    def server = Artifactory.newServer url: env.ARTIFACTORY_SERVER, credentialsId: 'your-credentials-id'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "dist/**",
                                "target": "${env.ARTIFACTORY_REPO}/${env.NODEJS_APP_NAME}/",
                                "props": "build.name=${env.JOB_NAME};build.number=${env.BUILD_NUMBER}"
                            }
                        ]
                    }"""
                    def buildInfo = server.upload spec: uploadSpec
                    echo "Published to Artifactory: ${env.ARTIFACTORY_REPO}/${env.NODEJS_APP_NAME}/"
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Define the Docker image name and tag
                    def dockerImage = 'your-docker-image-name:tag'
                    
                    // Build the Docker image using the specified Dockerfile
                    sh "docker build -t $dockerImage -f Dockerfile ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    // Specify your Docker image name and tag
                    def dockerImage = 'your-docker-image-name:tag'
                    
                    // Log in to the Docker registry (if needed)
                    withCredentials([usernamePassword(credentialsId: 'your-docker-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                    }
                    
                    // Push the Docker image to a container registry
                    sh "docker push $dockerImage"
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Initialize Terraform in your working directory
                bat 'terraform init'
            }
        }

        stage('Plan Terraform Changes') {
            steps {
                // Create an execution plan to review changes
                bat 'terraform plan -out=tfplan'
            }
        }

        stage('Apply Terraform Changes') {
            steps {
                // Apply the changes to create the AKS cluster
                bat 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Deploy to AKS') {
            steps {
                script {
                    def kubeconfigPath = sh(script: 'echo $KUBECONFIG', returnStdout: true).trim()
                    
                    // Set the image for the deployment
                    sh "kubectl --kubeconfig=$kubeconfigPath set image deployment/your-deployment-name your-container-name=$IMAGE_NAME"
                }
            }
        }
    }

    post {
        success {
            // Archive test reports or any build artifacts
            archiveArtifacts artifacts: 'path/to/your/artifacts/**', allowEmptyArchive: true
        }

        always {
            // Clean up any temporary build artifacts
            deleteDir()
        }
    }
}

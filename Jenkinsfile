pipeline {
    agent any

    environment {
        IMAGE_NAME = "thegoutham/supermariogitopsproject"
        IMAGE_TAG = "${BUILD_NUMBER}"
        SKIP_BUILD = "false"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/Goutham-3v/gitops-practice-devsecops-sonarqube-sast-scan-supermario-repo.git'
            }
        }

        stage('Check Skip CI') {
            steps {
                script {
                    def msg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Last commit message: ${msg}"

                    if (msg.contains("[skip ci]")) {
                        env.SKIP_BUILD = "true"
                        currentBuild.result = 'SUCCESS'
                        echo "Skipping build because commit contains [skip ci]"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { env.SKIP_BUILD == "false" }
            }
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Docker Login & Push') {
            when {
                expression { env.SKIP_BUILD == "false" }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            when {
                expression { env.SKIP_BUILD == "false" }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-token',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    git config user.email "jenkins@example.com"
                    git config user.name "jenkins"

                    sed -i "s|image: thegoutham/supermariogitopsproject:.*|image: thegoutham/supermariogitopsproject:$IMAGE_TAG|" k8s/deployment.yaml

                    git add k8s/deployment.yaml

                    git commit -m "ci: update image tag to $IMAGE_TAG [skip ci]" || echo "No changes to commit"

                    git pull origin main --rebase

                    git push https://$GIT_USER:$GIT_PASS@github.com/Goutham-3v/gitops-practice-devsecops-sonarqube-sast-scan-supermario-repo.git HEAD:main
                    '''
                }
            }
        }
    }
}
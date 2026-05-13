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

        stage('Check Commit') {
            steps {
                script {
                    def commitMsg = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    echo "Commit message: ${commitMsg}"
                    if (commitMsg.contains('[skip ci]') || commitMsg.contains('ci: update image tag')) {
                        currentBuild.result = 'NOT_BUILT'
                        error('Skipping automated commit - breaking the loop!')
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Docker Login & Push') {
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
                    git push https://$GIT_USER:$GIT_PASS@github.com/Goutham-3v/gitops-practice-devsecops-sonarqube-sast-scan-supermario-repo.git HEAD:main
                    '''
                }
            }
        }
    }
}
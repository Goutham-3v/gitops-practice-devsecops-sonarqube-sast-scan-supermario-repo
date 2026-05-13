pipeline {
    agent any

    environment {
        IMAGE_NAME = "thegoutham/supermariogitopsproject"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                url: 'https://github.com/Goutham-3v/gitops-practice-devsecops-sonarqube-sast-scan-supermario-repo.git'
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

        stage('Generate Image Tag') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: "cat version.txt",
                        returnStdout: true
                    ).trim()
                }

                echo "Image Tag: ${IMAGE_TAG}"
            }
        }

        stage('Update deployment.yaml') {
            steps {

                withCredentials([usernamePassword(
                    credentialsId: 'github-token',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {

                    sh '''
                    git config user.email "jenkins@example.com"
                    git config user.name "jenkins"

                    sed -i "s|image: thegoutham/supermariogitopsproject:.*|image: thegoutham/supermariogitopsproject:$IMAGE_TAG|" deployment.yaml

                    git add deployment.yaml

                    git commit -m "Updated image to version $IMAGE_TAG" || echo "No changes"

                    git push https://$GIT_USER:$GIT_PASS@github.com/Goutham-3v/gitops-practice-devsecops-sonarqube-sast-scan-supermario-repo.git HEAD:main
                    '''
                }
            }
        }


    }
}
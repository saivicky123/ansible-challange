pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-creds']
                ]) {
                    sh '''
                        set -e
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Wait for EC2 to be Ready') {
            steps {
                echo 'Waiting for instances to initialize...'
                sleep 45
            }
        }

        stage('Ansible Deploy') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'jenkins-ssh-key',
                        keyFileVariable: 'SSH_KEY_PATH',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e
                        ansible-playbook \
                          -i inventory.ini \
                          setup.yml \
                          -u "$SSH_USER" \
                          --private-key "$SSH_KEY_PATH" \
                          --ssh-common-args='-o StrictHostKeyChecking=no'
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
        always {
            cleanWs()
        }
    }
}

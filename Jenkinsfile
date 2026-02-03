pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        /* ---------------- CHECKOUT ---------------- */
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /* ---------------- TERRAFORM ---------------- */
        stage('Terraform Init & Apply') {
            steps {
                sh '''
                    set -e
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }

        /* ---------------- WAIT ---------------- */
        stage('Wait for EC2 to be Ready') {
            steps {
                echo "Waiting for instances to initialize..."
                sleep 45
            }
        }

        /* ---------------- ANSIBLE ---------------- */
        stage('Ansible Deploy') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY_PATH'
                    )
                ]) {
                    sh '''
                        set -e
                        chmod 600 $SSH_KEY_PATH

                        ansible-playbook -i inventory.ini setup.yml \
                          --private-key $SSH_KEY_PATH \
                          --ssh-common-args="-o StrictHostKeyChecking=no"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
        always {
            cleanWs()
        }
    }
}


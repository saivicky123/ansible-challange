pipeline {
    agent any
    environment {
        AWS_CREDENTIALS = credentials('aws-keys') // AWS Access/Secret
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve' [cite: 31]
            }
        }
        stage('Ansible Deploy') {
            steps {
                // Wait for SSH to become ready
                sleep 30 
                sh 'ansible-playbook -i inventory.ini setup.yml --private-key /path/to/sshless.pem'
            }
        }
    }
}

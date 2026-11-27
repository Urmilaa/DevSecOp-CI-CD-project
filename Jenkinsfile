
pipeline {

    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Automatically run apply after generating plan?'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        CLUSTER_NAME = 'demo-eks-cluster'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {

        // ==========================================
        // 1. CHECKOUT
        // ==========================================

        stage('Checkout') {
            steps {
                dir('terraform') {
                    deleteDir()

                    git branch: 'main',
                        url: 'https://github.com/Urmilaa/DevSecOp-CI-CD-project.git'
                }
            }
        }

        // ==========================================
        // 2. AWS AUTHENTICATION
        // ==========================================

        stage('AWS Authentication') {
            steps {
                sh '''
                    set -e

                    echo "===== AWS Identity ====="
                    aws sts get-caller-identity

                    echo "===== AWS Region ====="
                    aws configure get region || true
                '''
            }
        }

        // ==========================================
        // 3. TERRAFORM INIT
        // ==========================================

       /* stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e

                        echo "===== Terraform Init ====="

                        terraform init \
                            -input=false \
                            -reconfigure
                    '''
                }
            }
        }

        // ==========================================
        // 4. TERRAFORM VALIDATE
        // ==========================================

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e

                        terraform validate
                    '''
                }
            }
        }

        // ==========================================
        // 5. TERRAFORM PLAN
        // ==========================================

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e

                        echo "===== AWS Identity ====="
                        aws sts get-caller-identity

                        echo "===== Terraform Plan ====="

                        terraform plan \
                            -input=false \
                            -out=tfplan

                        echo "===== Terraform Plan Details ====="

                        terraform show -no-color tfplan > tfplan.txt

                        cat tfplan.txt
                    '''
                }
            }
        }

        // ==========================================
        // 6. MANUAL APPROVAL
        // ==========================================

        stage('Approval') {

            when {
                expression {
                    return !params.autoApprove
                }
            }

            steps {
                script {

                    def plan = readFile(
                        'terraform/tfplan.txt'
                    )

                    input(
                        message: """
                        Review the Terraform plan below.

                        Do you approve Terraform Apply?

                        ${plan}
                        """,
                        ok: 'Approve Terraform Apply'
                    )
                }
            }
        }

        // ==========================================
        // 7. TERRAFORM APPLY
        // ==========================================

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        set -e

                        echo "===== AWS Identity ====="
                        aws sts get-caller-identity

                        echo "===== Terraform Apply ====="

                        terraform apply \
                            -input=false \
                            tfplan
                    '''
                }
            }
        }  */

        // ==========================================
        // 8. CONFIGURE KUBECONFIG
        // ==========================================

        stage('Configure kubeconfig') {
            steps {
                sh '''
                    set -e

                    echo "===== AWS Identity ====="
                    aws sts get-caller-identity

                    echo "===== kubectl Version ====="
                    which kubectl
                    kubectl version --client

                    echo "===== Configure kubeconfig ====="

                    mkdir -p "$HOME/.kube"

                    aws eks update-kubeconfig \
                        --region "$AWS_DEFAULT_REGION" \
                        --name "$CLUSTER_NAME" \
                        --kubeconfig "$KUBECONFIG"

                    echo "===== Current Context ====="

                    kubectl config current-context

                    echo "Kubeconfig updated successfully."
                '''
            }
        }

        // ==========================================
        // 9. VERIFY EKS CLUSTER
        // ==========================================

        stage('Verify EKS Cluster') {
            steps {
                sh '''
                    set -e

                    echo "===== AWS Identity ====="
                    aws sts get-caller-identity

                    echo "===== Kubernetes Context ====="
                    kubectl config current-context

                    echo "===== Cluster Info ====="
                    kubectl cluster-info

                    echo "===== Cluster Nodes ====="
                    kubectl get nodes -o wide

                    echo "===== Namespaces ====="
                    kubectl get namespaces
                '''
            }
        }

        // ==========================================
        // 10. VALIDATE EKS RESOURCES
        // ==========================================

        stage('Validate EKS Resources') {
            steps {
                sh '''
                    set -e

                    echo "===== Kubernetes Nodes ====="
                    kubectl get nodes

                    echo "===== System Pods ====="
                    kubectl get pods -n kube-system

                    echo "===== Services ====="
                    kubectl get svc -A
                '''
            }
        }
    }

    post {
        success {
            echo 'Terraform deployment and EKS validation completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins console output.'
        }

        always {
            echo 'Jenkins pipeline execution completed.'
        }
    }
}

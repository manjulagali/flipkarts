pipeline {
    agent any

    stages{
        stage('Clone-Repo'){
            steps{
                checkout scm
            }
        }

        stage('build'){
            steps{
                sh 'mvn install'
            }
        }

        stage('Compile'){
            steps{
                sh 'mvn clean compine'
            }
        }

        stage('Package as WAR'){
            steps{
                sh 'mvn package'
            }
        }

        stage{'deployment'}{
            steps{
                sh 'scp target/hello-maven.war root@172.31.14.149:/home/ubuntu/tomcat/apache-tomcat-11.0.25/webapps'
            }
        }
    }
}

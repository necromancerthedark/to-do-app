pipeline {
    agent any
    environment {
    DOCKER_IMAGE_NAME = "necromancerthedark/kanban_image"
    DOCKER_USERNAME = "necromancerthedark"
    DOCKER_PASSWORD = credentials("DOCKER_SECRET")
    }
    stages {
        stage("Test") {
            steps{
                sh '''
                echo "running the tests ...."
                yarn test
                '''
                 }
                }

        stage("Build") {
                    steps{
                        sh '''
                        echo "building docker image ...."
                        docker build -t "${DOCKER_IMAGE_NAME}" -f Dockerfile .
                        '''
                         }
                        }
        stage("Push") {
                    steps{
                        sh '''
                        echo "pushing docker image ...."
                        docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                        docker tag "${DOCKER_IMAGE_NAME}" "${DOCKER_IMAGE_NAME}":"$BUILD_NUMBER"
                        docker push "${DOCKER_IMAGE_NAME}":"$BUILD_NUMBER"
                        docker push "${DOCKER_IMAGE_NAME}":latest

                        echo "cleaning up local images image ...."
                        docker rmi "${DOCKER_IMAGE_NAME}":"$BUILD_NUMBER"
                        docker rmi "${DOCKER_IMAGE_NAME}":latest
                        '''
                        }
                        }

        stage("Deploy") {
                            steps{
                                sh '''
                                echo "deploying the application ...."
                                docker rm -f kanban_container|| true
                                docker run -d -p 4444:80 --name kanban_container "${DOCKER_IMAGE_NAME}":latest
                                '''
                                }
                          }
                    }
                }
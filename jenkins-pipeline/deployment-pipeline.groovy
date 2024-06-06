pipeline {
    agent {label 'ststor01' }
    parameters {
         string defaultValue: 'master', name: 'BRANCH'
}
    environment {
      web_url_path = '/var/www/html'
    }

    stages {
        stage('Deploy') {
            steps {
                script {
                        if (params.BRANCH == 'master') {
                        git credentialsId: 'git_Cred', url: 'http://git.stratos.xfusioncorp.com/sarah/web_app.git'
                        }   else {
                        git branch: '${BRANCH}', credentialsId: 'git_Cred', url: 'http://git.stratos.xfusioncorp.com/sarah/web_app.git' 
                        }
                }
                sh '''echo 'Bl@kW' | sudo -S cp ${WORKSPACE}/* ${web_url_path}'''
                sh ''' ls -ll /var/www/html'''               
                }
        }
    }
}

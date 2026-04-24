pipeline {
    agent { label 'ansible-agent' }

    options {
        timeout(time: 90, unit: 'MINUTES')
    }

    stages {
        // --- LINTING ---
        // stage('Linting') {
        //     steps {
        //         script {
        //             sh """
        //                 podman run --rm -v \$(pwd):/app -w /app ruby:3.4 bash -c "
        //                     touch .enable_dev &&
        //                     sed -i '3isource \\"https://rubygems.org\\"' Gemfile &&
        //                     bundle install --jobs 4 --retry 3 &&
        //                     bundle exec rubocop -S &&
        //                     bundle exec slim-lint app/views
        //                 "
        //             """
        //         }
        //     }
        // }

        // --- TEST MATRIX ---

        stage('Tests') {
            matrix {
                axes {
                    axis { name 'RUBY_VER'; values '3.1', '3.2', '3.3', '3.4' }
                    axis { name 'REDMINE_VER'; values '6.0-stable', 'master' }
                    axis { name 'DB_TYPE'; values 'postgres', 'mysql' }
                }
                excludes {
                    exclude { axis { name 'RUBY_VER'; values '3.1' }; axis { name 'REDMINE_VER'; values 'master' } }
                    exclude { axis { name 'RUBY_VER'; values '3.4' }; axis { name 'REDMINE_VER'; values '6.0-stable' } }
                }
                
                stages {
                    stage('Integration Run') {
                        steps {
                            script {
                                def networkName = "net_${env.BUILD_ID}_${RUBY_VER}_${REDMINE_VER}_${DB_TYPE}"
                                def dbName = "db_${env.BUILD_ID}_${RUBY_VER}_${REDMINE_VER}_${DB_TYPE}"
                                def volumeName = "vol_${env.BUILD_ID}_${RUBY_VER}_${REDMINE_VER}_${DB_TYPE}"
                                
                                try {
                                    // Create a private network for this matrix cell
                                    sh "podman network create ${networkName}"

                                    // Start Database
                                    def dbImg = (DB_TYPE == 'postgres') ? 'postgres:16' : 'mysql:8.0'
                                    def dbEnv = (DB_TYPE == 'postgres') ? 
                                        "-e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres" : 
                                        "-e MYSQL_ROOT_PASSWORD=BestPasswordEver"
                                    
                                    sh "podman run -d --name ${dbName} --network ${networkName} ${dbEnv} ${dbImg}"
                                    // Wait a bit for db to be ready
                                    sh "sleep 300"

                                    // Run Application Logic
                                    // Create unique volume for this matrix cell to prevent conflicts
                                    sh "podman volume create ${volumeName}"
                                    sh """
                                        podman run --rm --network ${networkName} \
                                            -v ${volumeName}:/workspace -w /workspace \
                                            -v \$(pwd):/source \
                                            ruby:${RUBY_VER} bash -c "
                                            set -xe
                                            
                                            # Copy source files to workspace
                                            cp -r /source/* /workspace/
                                            cp -r /source/.[^.]* /workspace/ 2>/dev/null || true
                                            cp -r /source/..?* /workspace/ 2>/dev/null || true
                                            
                                            apt-get update && apt-get install -y build-essential cmake libicu-dev git ${DB_TYPE == 'mysql' ? 'default-libmysqlclient-dev' : 'libpq-dev'}
                                            
                                            git clone --branch ${REDMINE_VER} https://github.com/redmine/redmine.git redmine
                                            mkdir -p redmine/plugins/redmine_messenger
                                            # Copy only the plugin files, excluding the redmine directory itself
                                            find . -maxdepth 1 -not -name 'redmine' -not -name '.' -not -name '..' -exec cp -R {} redmine/plugins/redmine_messenger/ \\;
                                            cd redmine
                                            cp plugins/redmine_messenger/test/support/configuration.yml config/configuration.yml
                                            cp plugins/redmine_messenger/test/support/database-${DB_TYPE}.yml config/database.yml
                                            
                                            # Point to the container name in the podman network
                                            sed -i 's/localhost/${dbName}/g' config/database.yml
                                            
                                            bundle config set --local without 'development'
                                            bundle install --jobs=4 --retry=3
                                            
                                            export RAILS_ENV=test
                                            bundle exec rake generate_secret_token
                                            bundle exec rake db:create db:migrate redmine:plugins:migrate
                                            bundle exec rake db:test:prepare
                                            bundle exec rake redmine:plugins:test NAME=redmine_messenger RUBYOPT='-W0'
                                        "
                                    """
                                } finally {
                                    // Cleanup
                                    sh "podman rm -f ${dbName} || true"
                                    sh "podman network rm ${networkName} || true"
                                    sh "podman volume rm ${volumeName} || true"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
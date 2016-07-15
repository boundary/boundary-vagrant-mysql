# Explictly set to avoid warning message
Package {
  allow_virtual => false,
}

#include '::mysql::server'

class { '::mysql::server':
  root_password => 'root123',
}

file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile'
}

class { '::mysql::server::monitor':
  mysql_monitor_username => 'pulse',
  mysql_monitor_password => 'pulse123',
  mysql_monitor_hostname => '127.0.0.1',
}

node /^ubuntu/ {

  class { 'boundary':
    token => $api_token,
  }

}

# Separate the Cento 7.0 install until the boundary meter puppet package is fixed
node /^centos-7-0/ {

  package {'epel-release':
    ensure => 'installed',
  }

}

node /^centos/ {
   mysql::db { 'pulse':
    user     => 'pulse',
    password => 'pulse123',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
}

class { 'boundary':
    token => $api_token
  }
}

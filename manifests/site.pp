# Explictly set to avoid warning message

#include '::mysql::server'

class { '::mysql::server':
  root_password => 'root123',
#  package_ensure => '5.6.26',
}

class { '::mysql::server::monitor':
  mysql_monitor_username => 'boundary',
  mysql_monitor_password => 'boundary123',
  mysql_monitor_hostname => '127.0.0.1',
}


Package {
  allow_virtual => false,
}

node /^ubuntu/ {
  file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile'
  }

  exec { 'update-apt-packages':
    command => '/usr/bin/apt-get update -y',
    creates => '/vagrant/.locks/update-apt-packages',
  }


  class { 'boundary':
    token => $boundary_api_token,
  }

}

# Separate the Cento 7.0 install until the boundary meter puppet package is fixed
node /^centos-7-0/ {
  file { 'bash_profile':
    path    => '/home/vagrant/.bash_profile',
    ensure  => file,
    source  => '/vagrant/manifests/bash_profile'
  }

  exec { 'update-rpm-packages':
    command => '/usr/bin/yum update -y',
    creates => '/vagrant/.locks/update-rpm-packages',
  }

  package {'epel-release':
    ensure => 'installed',
    require => Exec['update-rpm-packages']
  }

}

node /^centos/ {
   mysql::db { 'boundary':
    user     => 'boundary',
    password => 'boundary123',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE'],
#    sql      => '/path/to/sqlfile',
#    import_timeout => 900,
}

#  file { 'bash_profile':
#    path    => '/home/vagrant/.bash_profile',
#    ensure  => file,
#    source  => '/vagrant/manifests/bash_profile'
#  }

#  exec { 'update-rpm-packages':
#    command => '/usr/bin/yum update -y',
#    creates => '/vagrant/.locks/update-rpm-packages',
#  }

 class { 'boundary':
    token => $boundary_api_token
  }

}

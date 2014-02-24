case $operatingsystem {
  'centos': {
    yumrepo { 'epel':
      mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-${::lsbmajdistrelease}&arch=${::architecture}",
    # failovermethod => 'priority',
    # proxy => $proxy,
      enabled => '1',
      gpgcheck => '0',
      gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::os_maj_version}",
      descr => "Extra Packages for Enterprise Linux ${::lsbmajdistrelease} - ${::architecture}"
    }
  }
}

class puppet_base {
  file { '/etc/puppet/hiera.yaml':
    ensure => 'present',
    source => 'puppet:///files/hiera.yaml',
  }
}

class mysql_server {
  $password = "'iNsSnS05T09!"


  case  $operatingsystem {
    centos:  {
      $mysql = ['mysql-server', 'mysql-devel.x86_64']
      $service = 'mysqld'
    }
    ubuntu: {
      $mysql = ['mysql-server', 'libmysqlclient-dev']
      $service = 'mysql'
    }
  }
  # case

  package { $mysql:
    ensure => 'present',
  }

  service { $service:
    ensure => 'running',
    enable => 'true',
    require => Package[$mysql],
  }

  exec { "Set MySQL server root password":
    require => Package[$mysql],
    path => "/bin:/usr/bin:/usr/sbin",
    unless => "mysqladmin -uroot -p$password status",
    command => "mysqladmin -uroot password $password",
  }
}

class vcs {
  $vcs = ['git', 'git-svn','subversion']

  case  $operatingsystem {
    'centos':  {
      $mysql = ['mysql-server', 'mysql-devel.x86_64']

      package { $vcs:
        ensure => 'installed',
        require => Yumrepo[ 'epel' ],
      }
    }
    'ubuntu': {
      $mysql = ['mysql-server', 'libmysqlclient-dev']

      package { $vcs:
      ensure => 'installed',
      }
    }
  }
}

class inspheris {
  $apache   = [ 'apache2','libapache2-mod-jk']
  $tomcat7  = ['tomcat7','tomcat7-common']
  $tools    = [ 'htop','nmap','vim','vim-common','emacs']
  $user     = inspheris
  $ant      = 'ant'

  package { $apache:
    ensure => 'installed',
  }
  package { $tomcat7:
    ensure => 'installed',
  }
## Install some utilities
  package { $tools:
    ensure => installed,
  }
  package { $ant:
    ensure => installed,
  }
  group { 'puppet':
    ensure => 'present',
  }
  group { $inspheris:
    ensure => present,
  }
  user { $inspheris:
    ensure => present,
    managehome => true,
  }
  file { '/home/inspheris':
    ensure => directory,
  }
  file { '/home/inspheris/assets':
    ensure  => present,
    owner => 'tomcat7',
    group => 'tomcat7',
    mode  => '1777',
  }
  file { '/home/inspheris/solr3':
    ensure  =>  present,
    owner   => 'tomcat7',
    group   => 'tomcat7',
    mode    => '0755',
  }
  file {'/var/lib/tomcat7/webapps':
    ensure => present,
    mode   =>  '0755',
    group  =>  'tomcat7',
    owner  =>  'tomcat7',
  }
  file { '/var/log/tomcat7':
    ensure  => prenset,
    mode    => '0755',
    group   => 'tomcat7',
    owner   => 'tomcat7',
  }

  file {'/home/inspheris/code':
    ensure  => 'link',
    target  => '/var/lib/tomcat7/webapps',
    require => Package['tomcat7'],
  }


  File { owner => 0, group => 0, mode => 0644 }

  file { '/etc/motd':
    content => "Welcome to your Vagrant-built virtual machine!
    Managed by Puppet.\n"
  }

  file { '/etc/hosts':
    ensure => 'present',
    source => 'puppet:///files/hosts',
  }

  case $operatingsystem {
    centos:  {
      $common = ['redhat-lsb.x86_64']
      $utils = ['nfs-utils.x86_64','gcc','ruby-devel', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel']
      $mux = ['tmux', 'screen']
      package {[ $common, $utils, $mux ]:
        ensure => 'installed',
        require => Yumrepo['epel'],
      }
    }
    ubuntu: {
      $common = ['screen']
      $utils = ['rpcbind', 'nfs-common']
      $mux = ['tmux']
      package {[ $common, $utils, $mux ]:
        ensure => 'installed',
      }
    }
  }

  include puppet_base
  include mysql_server
  include vcs
}

include inspheris

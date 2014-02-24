#!/bin/bash
## Decription: Installation of ruby and puppet version upgradation before vagrant provision
## Author: Shishir Sharma and Ramesh Kumar
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vagrant_ruby/bin'
distro=`facter operatingsystem`

#distro=`lsb_release -i | cut -d":" -f2`

if [[ $distro = "Ubuntu" ]]; then

    dpkg -s puppet >/dev/null  2>&1

    if [ $? -eq 0 ]; then
        current_puppet_version=`dpkg -s puppet| grep Version | cut -d":" -f2`
    else
        current_puppet_version=`puppet -V`
    fi

    dpkg --compare-versions $current_puppet_version lt "3.2"

    if [ $? -eq 0 ]; then
        echo "Updating Puppet to latest release"
        [ $? -eq 0 ] && echo "Downloading..." && rm -rf puppetlabs-release-precise.*
        [ $? -eq 0 ] && wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb > /dev/null 2>&1
        [ $? -eq 0 ] && echo "Adding repository sources..."
        [ $? -eq 0 ] && dpkg -i puppetlabs-release-precise.deb
        [ $? -eq 0 ] && echo "Updting sources..."
        [ $? -eq 0 ] && apt-get update > /dev/null  2>&1
        [ $? -eq 0 ] && echo "Installing puppet..."
        [ $? -eq 0 ] && apt-get -y install puppet > /dev/null  2>&1
        [ $? -eq 0 ] && echo "Cleanup..."
        [ $? -eq 0 ] && rm -rf puppetlabs-release-precise.deb
    else
        echo "Puppet already on 3.2"
    fi
  else
    # For CentOS-5.x specific
    if [[ $distro = "CentOS" ]]; then

      echo "Installing EPEL, RBEL and Puppetlabs repo..."

       [[ `rpm -qa epel-release` = 'epel-release-5-4' ]] || rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

       [[ `rpm -qa rbel5-release` = 'rbel5-release-1.0-2.el5' ]] || rpm -ivh http://rbel.co/rbel5

       [[ `rpm -qa puppetlabs-release` = 'puppetlabs-release-5-7' ]] || rpm -ivh http://yum.puppetlabs.com/el/5/products/x86_64/puppetlabs-release-5-7.noarch.rpm

       [[ `rpm -qa puppet` = 'puppet-3.2.4-1.el5' ]] || yum -y install puppet

       echo "Your current Puppet version is: `puppet -V` now"
    fi
fi

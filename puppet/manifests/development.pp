class install-npm-packages{
  $npmPackages = ['bower']
  package{ $npmPackages:
    ensure => 'installed',
    provider => 'npm',
    before => Class['ko-bower-install'],
    require => Class['nodejs']
  }
}

$nodepath = ["/usr/local/node/node-default/bin", "/usr/local/sbin", "/usr/local/bin",
"/usr/sbin", "/usr/bin", "/sbin", "/bin", "/usr/games", "/opt/vagrant_ruby/bin"]

class ko-npm-install{
  exec{ "npm install 2> help.log": #not sure why npm install is now failing.
                                    #Test fresh at work
    creates => "/vagrant/node_modules",
    cwd => "/vagrant",
    path => $nodepath,
    require => Class['nodejs'],
    user => "vagrant"
  }
}

class ko-bower-install{
  exec{ "bower install":
    creates => "/vagrant/src/public/vendor",
    cwd => "/vagrant",
    path => $nodepath,
    require => Class["install-npm-packages"],
    user => "vagrant"
  }
}

include git
include nodejs
include install-npm-packages
include ko-npm-install
include ko-bower-install

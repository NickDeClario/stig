name             'stig' # ~FC121
maintainer       'USGS WMA EB'
maintainer_email 'isuftin@usgs.gov'
license          'CPL-1.0'
description      'Installs/Configures CIS STIG benchmarks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.16'
source_url       'https://github.com/USGS-CIDA/stig'
issues_url       'https://github.com/USGS-CIDA/stig/issues'

supports         'centos', '>= 6.6'
supports         'centos', '>= 7.1'
supports         'ubuntu'

chef_version     '>= 14.0.0'

depends          'logrotate'

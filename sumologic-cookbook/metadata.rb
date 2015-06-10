name             'sumologic-collector'
maintainer       'Ben Newton'
maintainer_email 'ben@sumologic.com'
license          'Apache v2.0'
description      'Installs/Configures sumologic-collector'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.4'
attribute 'sumologic/credentials/bag_name',
  :display_name => "Credentials bag name",
  :type => "string",
  :required => "required"
attribute 'sumologic/credentials/item_name',
  :display_name => "Credentials item name",
  :type => "string",
  :required => "required"

depends 'sumologic-collector'

recipe 'sumologic', 'Installs Sumo Logic collector, and provides resources for forwarding logs to sumologic'

#depends 'java'
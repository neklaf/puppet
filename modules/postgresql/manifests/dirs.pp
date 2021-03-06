# Class: postgresql::dirs
#
# This class creates postgresql directories. It's split off from the rest of the
# classes in order to allow requiring it without causing dependency loops. You
# should not be using it directly
#
# Parameters:
#   pgversion
#       Defaults to 9.6 in Debian Stretch and 11 in Buster
#       FIXME: Just use the unversioned package name and let apt
#       do the right thing.
#   ensure
#       Defaults to present
#   root_dir
#       The root directory for postgresql data. The actual directory will be
#       "${root_dir}/${pgversion}/main".
#
# Actions:
#  Create postgres directories
#
# Requires:
#
# Sample Usage:
#  include postgresql::dirs
#
class postgresql::dirs(
    $pgversion        = $::lsbdistcodename ? {
        'buster'  => '11',
        'stretch' => '9.6',
    },
    $ensure           = 'present',
    $root_dir         = '/var/lib/postgresql',
) {
    $data_dir = "${root_dir}/${pgversion}/main"
    file {  [ $root_dir, "${root_dir}/${pgversion}" ] :
        ensure => ensure_directory($ensure),
        owner  => 'postgres',
        group  => 'postgres',
        mode   => '0755',
    }

    file { $data_dir:
        ensure => ensure_directory($ensure),
        owner  => 'postgres',
        group  => 'postgres',
        mode   => '0700',
    }
}

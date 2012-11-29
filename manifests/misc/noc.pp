# https://noc.wikimedia.org/

class misc::noc-wikimedia {
	system_role { "misc::noc-wikimedia": description => "noc.wikimedia.org" }

	package { [ "apache2", "libapache2-mod-php5", "libapache2-mod-passenger", "libsinatra-ruby", "rails" ]:
		ensure => latest;
	}

	include passwords::ldap::wmf_cluster
	$proxypass = $passwords::ldap::wmf_cluster::proxypass

	file {
		"/etc/apache2/sites-available/noc.wikimedia.org":
			require => [ Apache_module[userdir], Apache_module[cgi], Package[libapache2-mod-php5] ],
			path => "/etc/apache2/sites-available/noc.wikimedia.org",
			mode => 0444,
			owner => root,
			group => root,
			source => "puppet:///files/apache/sites/noc.wikimedia.org";
		"/etc/apache2/sites-available/graphite.wikimedia.org":
			path => "/etc/apache2/sites-available/graphite.wikimedia.org",
			content => template('apache/sites/graphite.wikimedia.org'),
			mode => 0440,
			owner => root,
			group => www-data;
		"/usr/lib/cgi-bin":
			source => "puppet:///files/cgi-bin/noc/",
			recurse => true,
			ignore => ".svn",
			ensure => present;
	}

	apache_module { php5: name => "php5" }
	apache_module { userdir: name => "userdir" }
	apache_module { cgi: name => "cgi" }
	apache_module { ldap: name => "ldap" }
	apache_module { authnz_ldap: name => "authnz_ldap" }
	apache_module { proxy: name => "proxy" }
	apache_module { proxy_http: name => "proxy_http" }
	apache_module { ssl: name => "ssl" }

	apache_site { noc: name => "noc.wikimedia.org" }
	apache_site { graphiteproxy: name => "graphite.wikimedia.org" }

	service { apache2:
		require => [ Package[apache2], Apache_module[userdir], Apache_module[cgi], Apache_site[noc] ],
		subscribe => [ Package[libapache2-mod-php5], Apache_module[userdir], Apache_module[cgi], Apache_site[noc], File["/etc/apache2/sites-available/noc.wikimedia.org"] ],
		ensure => running;
	}

	# Monitoring
	monitor_service { "http": description => "HTTP", check_command => "check_http_url!noc.wikimedia.org!http://noc.wikimedia.org" }
}


-- SSH host definitions for WezTerm SSH domains and launcher menu.
-- Source of truth: configs/ssh/config
-- Default user: nikita.gasov (applied in ssh.lua, omitted here)
-- Default port: 22 (omitted when standard)

return {
  -- GitLab
  { name = 'gitlab',        group = 'GitLab', host = '10.0.0.230', port = 2112 },
  { name = 'gitlab-runner', group = 'GitLab', host = '10.0.0.231' },

  -- Test Servers
  { name = 'stage',  group = 'Test Servers', host = '10.0.1.18', cmd = 'cd /opt/pharmhub' },
  { name = 'test01', group = 'Test Servers', host = '10.0.1.10',             cmd = 'cd /opt/pharmhub' },
  { name = 'test02', group = 'Test Servers', host = '10.0.1.11', cmd = 'cd /opt/pharmhub' },
  { name = 'test03', group = 'Test Servers', host = '10.0.1.12', cmd = 'cd /opt/pharmhub' },
  { name = 'test04', group = 'Test Servers', host = '10.0.1.13',             cmd = 'cd /opt/pharmhub' },
  { name = 'test05', group = 'Test Servers', host = '10.0.1.14',             cmd = 'cd /opt/pharmhub' },
  { name = 'test06', group = 'Test Servers', host = '10.0.1.17',             cmd = 'cd /opt/pharmhub' },
  { name = 'test07', group = 'Test Servers', host = '10.0.1.15',             cmd = 'cd /opt/pharmhub' },
  { name = 'test08', group = 'Test Servers', host = '10.0.1.19',             cmd = 'cd /opt/pharmhub' },
  { name = 'test09', group = 'Test Servers', host = '10.0.1.23',             cmd = 'cd /opt/pharmhub' },
  { name = 'test10', group = 'Test Servers', host = '10.0.1.24', cmd = 'cd /opt/pharmhub' },
  { name = 'test11', group = 'Test Servers', host = '10.0.1.28',             cmd = 'cd /opt/pharmhub' },

  -- ClickHouse PROD
  { name = 'ch-s1-r1', group = 'ClickHouse PROD', host = '10.0.0.182' },
  { name = 'ch-s1-r2', group = 'ClickHouse PROD', host = '10.0.0.185' },
  { name = 'ch-s2-r1', group = 'ClickHouse PROD', host = '10.0.0.183' },
  { name = 'ch-s2-r2', group = 'ClickHouse PROD', host = '10.0.0.186' },
  { name = 'ch-s3-r1', group = 'ClickHouse PROD', host = '10.0.0.184' },
  { name = 'ch-s3-r2', group = 'ClickHouse PROD', host = '10.0.0.187' },

  -- ClickHouse Keeper
  { name = 'chk-1', group = 'ClickHouse Keeper', host = '10.0.0.135' },
  { name = 'chk-2', group = 'ClickHouse Keeper', host = '10.0.0.136' },
  { name = 'chk-3', group = 'ClickHouse Keeper', host = '10.0.0.137' },
  { name = 'chk-4', group = 'ClickHouse Keeper', host = '10.0.0.138' },
  { name = 'chk-5', group = 'ClickHouse Keeper', host = '10.0.0.139' },

  -- ClickHouse DEV
  { name = 'clickhouse-test1', group = 'ClickHouse DEV', host = '10.0.1.25' },
  { name = 'clickhouse-test2', group = 'ClickHouse DEV', host = '10.0.1.26' },
  { name = 'clickhouse-test3', group = 'ClickHouse DEV', host = '10.0.1.27' },
  { name = 'dev-ch-s1-r1',    group = 'ClickHouse DEV', host = '10.0.1.41' },
  { name = 'dev-ch-s2-r1',    group = 'ClickHouse DEV', host = '10.0.1.42' },
  { name = 'dev-ch-s3-r1',    group = 'ClickHouse DEV', host = '10.0.1.43' },

  -- PostgreSQL
  { name = 'psql-master', group = 'PostgreSQL', host = '10.0.0.170' },
  { name = 'psql1',       group = 'PostgreSQL', host = '10.0.0.171' },
  { name = 'psql2',       group = 'PostgreSQL', host = '10.0.0.172' },
  { name = 'psql3',       group = 'PostgreSQL', host = '10.0.0.173' },
  { name = 'psql4',       group = 'PostgreSQL', host = '10.0.0.174' },
  { name = 'psql5',       group = 'PostgreSQL', host = '10.0.0.175' },
  { name = 'psql6',       group = 'PostgreSQL', host = '10.0.0.176' },

  -- Vertica
  { name = 'vsql1-1', group = 'Vertica', host = '10.0.0.132' },
  { name = 'vsql2-1', group = 'Vertica', host = '10.0.1.4' },
  { name = 'vsql3-1', group = 'Vertica', host = '10.0.0.161' },

  -- Application
  { name = 'app-kz',       group = 'Application', host = '10.0.0.200', cmd = 'cd /opt/pharmhub' },
  { name = 'app-ru',       group = 'Application', host = '10.0.0.154', cmd = 'cd /opt/pharmhub' },
  { name = 'matchflow-kz', group = 'Application', host = '10.0.0.201', cmd = 'cd /opt/pharmhub' },
  { name = 'matchflow-ru', group = 'Application', host = '10.0.0.155', cmd = 'cd /opt/pharmhub' },

  -- Docker
  { name = 'docker-2-ru', group = 'Docker', host = '10.0.0.152',             cmd = 'cd /opt/pharmhub' },
  { name = 'docker-kz',   group = 'Docker', host = '10.0.0.202',             cmd = 'cd /opt/pharmhub' },
  { name = 'docker-ru',   group = 'Docker', host = '10.0.0.153', cmd = 'cd /opt/pharmhub' },

  -- Gate
  { name = 'gate-dev',    group = 'Gate', host = '10.0.1.2' },
  { name = 'gate-prod',   group = 'Gate', host = '10.0.0.130' },
  { name = 'gate-reg-ru', group = 'Gate', host = '89.108.123.251', port = 2200 },

  -- Storage & FTP
  { name = 'ftp',      group = 'Storage & FTP', host = '10.0.0.156' },
  { name = 'ftp-dev',  group = 'Storage & FTP', host = '89.108.120.2' },
  { name = 'ftp-new',  group = 'Storage & FTP', host = '213.232.228.181', port = 2200 },
  { name = 'storage1', group = 'Storage & FTP', host = '10.0.0.146' },
  { name = 'storage2', group = 'Storage & FTP', host = '10.0.0.147' },
  { name = 'storagev', group = 'Storage & FTP', host = '10.0.0.145' },

  -- ML
  { name = 'ml1',     group = 'ML', host = '10.0.0.143' },
  { name = 'ml1-dev', group = 'ML', host = '10.0.1.8' },
  { name = 'ml2',     group = 'ML', host = '10.0.0.144' },

  -- External
  { name = 'justhost-root',      group = 'External', host = '92.114.54.221',  port = 2200 },
  { name = 'nginx-proxy',        group = 'External', host = '185.146.3.64' },
  { name = 'ph-vdsina-nl-root',  group = 'External', host = '62.84.96.158' },
  { name = 'selectel-proxy',     group = 'External', host = '213.232.228.180' },
  { name = 'the.hostring-nl-root', group = 'External', host = '94.131.107.93' },
  { name = 'vdsina-nl-root',     group = 'External', host = '77.246.109.115' },

  -- Other
  { name = 'jasper',   group = 'Other', host = '10.10.110.19' },
  { name = 'metabase', group = 'Other', host = '10.0.0.234' },
  { name = 'wiki',     group = 'Other', host = '10.0.0.247' },
}

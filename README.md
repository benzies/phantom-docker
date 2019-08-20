# The beginning...

1. Start your container.

      - docker run -it -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name phantosd --hostname phantosd -p "80:80" -p "443:443" centos/systemd

2. Enter your container and run the commands. (docker exec -it phantosd /bin/bash)


      - yum update -y
      - rpm -Uvh https://repo.phantom.us/phantom/4.5/base/7/x86_64/phantom_repo-4.5.15922-1.x86_64.rpm
      - /opt/phantom/bin/phantom_setup.sh install --no-prompt
      
 3. ???
 
 4. PROFIT!
 
# Build the container locally
```
git clone https://github.com/benzies/phantom-docker.git && \
docker build -t phantom . && \
docker run -it -d --privileged --name phantosd --hostname phantosd -p "443:443" phantom
```


 
 Note: You NEED a phantom login, so you can download and install the software. This is a pretty crappy way to make it, it's unoffical, and I will eventually improve it. You can start and stop the container as normal and everything fires back up just fine.  


"The begining..." is still the most effective method to getting Phantom in a container.  The latest method is still not recommended, it builds but I can't seem to authenticate to phatom... and now I'm tired. Eventually I would like to see the dependent services seperated into seperate containers. But hey... it took a year to get here, maybe next year?

#TODO
Authentication to Phantom seems to fail...

#### Packages/Apps for Phantom
```
  * phantom_abuseipdb.x86_64 0:1.0.9-1
  * phantom_alertfind.x86_64 0:1.0.12-1
  * phantom_alexa.x86_64 0:1.0.9-1
  * phantom_alibabaram.x86_64 0:1.0.3-1
  * phantom_alienvaultotx.x86_64 0:1.0.3-1
  * phantom_apivoid.x86_64 0:1.0.3-1
  * phantom_arboraps.x86_64 0:1.0.9-1
  * phantom_archer.x86_64 0:1.0.51-1
  * phantom_arcsight.x86_64 0:1.2.33-1
  * phantom_athena.x86_64 0:1.0.6-1
  * phantom_autofocus.x86_64 0:1.0.21-1
  * phantom_awscloudtrail.x86_64 0:1.0.4-1
  * phantom_awsec2.x86_64 0:1.0.7-1
  * phantom_awsguardduty.x86_64 0:1.0.2-1
  * phantom_awsiam.x86_64 0:1.0.7-1
  * phantom_awsinspector.x86_64 0:1.0.2-1
  * phantom_awslambda.x86_64 0:1.0.2-1
  * phantom_awss3.x86_64 0:1.0.12-1
  * phantom_awssecurityhub.x86_64 0:1.1.6-1
  * phantom_awssystemsmanager.x86_64 0:1.0.6-1
  * phantom_awswaf.x86_64 0:1.0.5-1
  * phantom_azureadgraph.x86_64 0:1.0.6-1
  * phantom_berryio.x86_64 0:1.0.8-1
  * phantom_bigfix.x86_64 0:1.0.11-1
  * phantom_bigquery.x86_64 0:1.0.4-1
  * phantom_bmcremedy.x86_64 0:1.0.15-1
  * phantom_carbonblack.x86_64 0:1.2.100-1
  * phantom_carbonblackdefense.x86_64 0:1.0.3-1
  * phantom_cbprotect.x86_64 0:1.0.33-1
  * phantom_censys.x86_64 0:1.0.26-1
  * phantom_certly.x86_64 0:1.0.9-1
  * phantom_checkpoint.x86_64 0:1.0.17-1
  * phantom_cherwell.x86_64 0:1.0.9-1
  * phantom_ciscoasa.x86_64 0:1.2.17-1
  * phantom_ciscocatalyst.x86_64 0:1.2.13-1
  * phantom_ciscoesa.x86_64 0:1.0.9-1
  * phantom_ciscoise.x86_64 0:1.2.17-1
  * phantom_ciscospark.x86_64 0:1.0.7-1
  * phantom_cloudpassagehalo.x86_64 0:1.0.8-1
  * phantom_code42.x86_64 0:1.0.5-1
  * phantom_confluence.x86_64 0:1.0.5-1
  * phantom_crits.x86_64 0:1.0.14-1
  * phantom_crowdstrike.x86_64 0:1.2.41-1
  * phantom_crowdstrikeoauthapi.x86_64 0:1.0.3-1
  * phantom_cuckoo.x86_64 0:1.3.17-1
  * phantom_cylance.x86_64 0:1.0.36-1
  * phantom_cymon.x86_64 0:1.0.12-1
  * phantom_cyphort.x86_64 0:1.2.37-1
  * phantom_deepsight.x86_64 0:1.0.19-1
  * phantom_dns.x86_64 0:1.3.32-1
  * phantom_dnsdb.x86_64 0:1.0.12-1
  * phantom_domaintools.x86_64 0:1.0.46-1
  * phantom_dshield.x86_64 0:1.0.8-1
  * phantom_elasticsearch.x86_64 0:1.2.3-1
  * phantom_elsa.x86_64 0:1.0.13-1
  * phantom_empire.x86_64 0:1.0.14-1
  * phantom_endgame.x86_64 0:1.0.9-1
  * phantom_ewsexchange.x86_64 0:1.0.137-1
  * phantom_falconapi.x86_64 0:1.0.32-1
  * phantom_fireamp.x86_64 0:1.0.21-1
  * phantom_fireeyehx.x86_64 0:1.0.25-1
  * phantom_firesight.x86_64 0:1.2.15-1
  * phantom_forescoutcounteract.x86_64 0:1.0.3-1
  * phantom_fortigate.x86_64 0:1.0.15-1
  * phantom_generator.x86_64 0:3.0.2-1
  * phantom_git.x86_64 0:1.0.14-1
  * phantom_github.x86_64 0:1.0.5-1
  * phantom_googledrive.x86_64 0:1.0.11-1
  * phantom_grr.x86_64 0:1.0.7-1
  * phantom_gsgmail.x86_64 0:1.0.14-1
  * phantom_hackertarget.x86_64 0:1.0.17-1
  * phantom_haveibeenpwned.x86_64 0:1.0.10-1
  * phantom_hipchat.x86_64 0:1.0.5-1
  * phantom_honeydb.x86_64 0:1.0.5-1
  * phantom_http.x86_64 0:2.1.15-1
  * phantom_imap.x86_64 0:2.0.20-1
  * phantom_infobloxddi.x86_64 0:1.0.10-1
  * phantom_insightvm.x86_64 0:1.0.10-1
  * phantom_ipstack.x86_64 0:1.0.5-1
  * phantom_isightpartners.x86_64 0:1.2.27-1
  * phantom_isitphishing.x86_64 0:1.0.6-1
  * phantom_ivanti_itsm.x86_64 0:1.0.15-1
  * phantom_ixianetworkpacketbroker.x86_64 0:1.0.3-1
  * phantom_jira.x86_64 0:2.0.32-1
  * phantom_joesandboxv2.x86_64 0:1.0.2-1
  * phantom_junipersrx.x86_64 0:1.2.17-1
  * phantom_kafka.x86_64 0:1.2.7-1
  * phantom_kennasecurity.x86_64 0:1.0.6-1
  * phantom_knowthycustomer.x86_64 0:1.0.5-1
  * phantom_koodous.x86_64 0:1.0.8-1
  * phantom_lastline.x86_64 0:1.2.41-1
  * phantom_ldap.x86_64 0:1.2.40-1
  * phantom_logrhythmsiem.x86_64 0:1.0.11-1
  * phantom_macvendors.x86_64 0:1.0.2-1
  * phantom_malshare.x86_64 0:1.0.15-1
  * phantom_malwaredomainlist.x86_64 0:1.0.11-1
  * phantom_malwr.x86_64 0:1.0.23-1
  * phantom_mas.x86_64 0:1.0.16-1
  * phantom_mattermost.x86_64 0:1.0.6-1
  * phantom_maxmind.x86_64 0:1.2.22-1
  * phantom_mcafeeepo.x86_64 0:1.0.21-1
  * phantom_metadefender.x86_64 0:1.0.11-1
  * phantom_mfeesm.x86_64 0:2.0.4-1
  * phantom_microsoftazurecompute.x86_64 0:1.0.10-1
  * phantom_microsoftonedrive.x86_64 0:1.0.5-1
  * phantom_microsoftsccm.x86_64 0:1.0.10-1
  * phantom_microsoftscom.x86_64 0:1.0.11-1
  * phantom_microsoftsqlserver.x86_64 0:1.0.7-1
  * phantom_microsoftteams.x86_64 0:1.0.6-1
  * phantom_mimecast.x86_64 0:1.0.10-1
  * phantom_misp.x86_64 0:1.0.19-1
  * phantom_mnemonic.x86_64 0:1.0.4-1
  * phantom_mobileiron.x86_64 0:1.0.13-1
  * phantom_moloch.x86_64 0:1.0.9-1
  * phantom_mongodb.x86_64 0:1.0.4-1
  * phantom_msgfileparser.x86_64 0:1.0.16-1
  * phantom_msgraphoffice365.x86_64 0:1.0.20-1
  * phantom_mxtoolbox.x86_64 0:1.0.17-1
  * phantom_myip.x86_64 0:1.0.3-1
  * phantom_mysql.x86_64 0:1.0.20-1
  * phantom_nessus.x86_64 0:1.0.9-1
  * phantom_netskope.x86_64 0:1.0.4-1
  * phantom_netwitness.x86_64 0:1.0.23-1
  * phantom_netwitnessendpoint.x86_64 0:1.0.16-1
  * phantom_nmap.x86_64 0:1.0.26-1
  * phantom_office365.x86_64 0:1.0.100-1
  * phantom_okta.x86_64 0:1.0.7-1
  * phantom_opendnsinvestigate.x86_64 0:1.2.25-1
  * phantom_opendnsumbrella.x86_64 0:1.2.20-1
  * phantom_osxcollector.x86_64 0:2.0.6-1
  * phantom_pagerduty.x86_64 0:1.0.27-1
  * phantom_pan.x86_64 0:1.2.26-1
  * phantom_panorama.x86_64 0:1.1.6-1
  * phantom_parser.x86_64 0:1.0.21-1
  * phantom_passivetotal.x86_64 0:1.2.36-1
  * phantom_phantom.x86_64 0:2.1.17-1
  * phantom_phishinginitiative.x86_64 0:1.0.9-1
  * phantom_phishlabs.x86_64 0:1.0.6-1
  * phantom_phishme.x86_64 0:1.0.20-1
  * phantom_phishtank.x86_64 0:1.0.19-1
  * phantom_pipl.x86_64 0:1.0.2-1
  * phantom_postgresql.x86_64 0:1.0.14-1
  * phantom_protectwise.x86_64 0:1.0.32-1
  * phantom_qradar.x86_64 0:1.2.62-1
  * phantom_qualys_ssllabs.x86_64 0:1.0.14-1
  * phantom_redlock.x86_64 0:1.0.2-1
  * phantom_remedyforce.x86_64 0:1.0.9-1
  * phantom_restingest.x86_64 0:1.2.32-1
  * phantom_reversinglabs.x86_64 0:1.2.26-1
  * phantom_ripe.x86_64 0:1.0.7-1
  * phantom_rsasa.x86_64 0:1.0.34-1
  * phantom_rss.x86_64 0:1.0.12-1
  * phantom_rt.x86_64 0:1.2.25-1
  * phantom_safebrowsing.x86_64 0:1.0.11-1
  * phantom_salesforce.x86_64 0:1.0.18-1
  * phantom_securitycenter.x86_64 0:1.3.15-1
  * phantom_sentinelone.x86_64 0:1.2.11-1
  * phantom_sep.x86_64 0:1.0.41-1
  * phantom_sep14.x86_64 0:1.0.23-1
  * phantom_servicenow.x86_64 0:1.2.51-1
  * phantom_slack.x86_64 0:1.2.21-1
  * phantom_smtp.x86_64 0:1.2.49-1
  * phantom_soltraedge.x86_64 0:1.2.27-1
  * phantom_splunk.x86_64 0:1.3.23-1
  * phantom_sqlite.x86_64 0:1.0.13-1
  * phantom_ssh.x86_64 0:1.0.47-1
  * phantom_ssmachine.x86_64 0:1.4.31-1
  * phantom_symanteccas.x86_64 0:1.0.17-1
  * phantom_symantecdlp.x86_64 0:1.0.8-1
  * phantom_symantecmessaginggateway.x86_64 0:1.0.4-1
  * phantom_symantecsa.x86_64 0:1.0.15-1
  * phantom_tala.x86_64 0:1.0.9-1
  * phantom_tanium.x86_64 0:1.2.41-1
  * phantom_thehive.x86_64 0:1.0.12-1
  * phantom_threatconnect.x86_64 0:1.0.69-1
  * phantom_threatcrowd.x86_64 0:1.0.19-1
  * phantom_threatgrid.x86_64 0:1.2.38-1
  * phantom_threatstream.x86_64 0:1.0.24-1
  * phantom_timer.x86_64 0:1.0.3-1
  * phantom_tor.x86_64 0:1.0.6-1
  * phantom_trustar.x86_64 0:1.0.19-1
  * phantom_tufinsecuretrack.x86_64 0:1.0.7-1
  * phantom_twilio.x86_64 0:1.0.9-1
  * phantom_unshortenme.x86_64 0:1.0.6-1
  * phantom_urlscan.x86_64 0:1.0.7-1
  * phantom_urlvoid.x86_64 0:1.0.20-1
  * phantom_venafi.x86_64 0:1.0.3-1
  * phantom_victorops.x86_64 0:1.0.12-1
  * phantom_virustotal.x86_64 0:1.2.52-1
  * phantom_volatility.x86_64 0:1.2.30-1
  * phantom_vsphere.x86_64 0:1.2.31-1
  * phantom_watsonlanguage.x86_64 0:1.0.6-1
  * phantom_whois.x86_64 0:1.2.38-1
  * phantom_whois_rdap.x86_64 0:1.0.14-1
  * phantom_wigle.x86_64 0:1.0.2-1
  * phantom_wildfire.x86_64 0:1.0.37-1
  * phantom_windowsdefenderatp.x86_64 0:1.0.4-1
  * phantom_winrm.x86_64 0:1.0.19-1
  * phantom_wmi.x86_64 0:1.2.27-1
  * phantom_xmatters.x86_64 0:1.0.12-1
  * phantom_zendesk.x86_64 0:1.2.28-1
  * phantom_zscaler.x86_64 0:1.0.20-1
```

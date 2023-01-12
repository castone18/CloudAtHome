# CloudAtHome
Docker containers for implementing personal cloud services economically.

## Rationale

With the availability of gigabit internet access to the home it becomes viable to economically
run a personal cloud server in your home. Doing so allows one to regain control over their data.
One can stop using Gmail so Google doesn't read all your email, one can retain control over their
photos, and more.

CloudAtHome attempts to make it easy to implement the following:
* A [Nextcloud](https://nextcloud.com) server running on a linux server in your home. One can
use an old laptop or desktop for this server. Nextcloud provides services such as photo 
backup from your devices, password storage and sync with all your devices, web based email
client, file sharing, and many more.
* An [OpenVPN](https://openvpn.net) server running on an inexpensive Virtual Private Server
from a VPS provider. The author uses a $5 USD/month vps from [Dynu](https://www.dynu.com). The
in home nextcloud server connects as a client to this VPN server avoiding the In Home Server
Issues below.
* A [Ghost](https://ghost.org) server running on the vps to provide a personal blog.
* A [Caddy](https://caddyserver.com) web server running on the vps in reverse proxy mode to expose
the in home server to the Intenet and to provide automatic free SSL certificates from LetsEncrypt.

### In Home Server Issues

One of the issues to overcome when running a cloud server in your home is that many Internet
Service Providers prevent it. Some ISP's block incoming TCP syn packets, which prevents the setup
of a TCP connection to your server. Other ISP's share IPv4 addresses between many customers. This 
breaks dynamic DNS since your IP address is not unique to you and your server cannot be addressed 
through it. To overcome these scenarios, one can run a VPN server on an inexpensive virtual private 
server then access the home server through the VPN. The home server sets up a client connection to 
the vps server and a reverse proxy web server on the vps directs all access to the nextcloud server 
through that vpn client connection.

There are a lot of technical details to implementing this concept and CloudAtHome attempts to encapsulate
that knowledge into scripts that make it easy to set up.

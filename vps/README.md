# CloudAtHome Installation

Follow this guideline to install CloudAtHome on a VPS.

CloudAtHome is only supported on a debian based linux distribution. It is assumed both the vps and the in home computer both run a linux distribution such as Ubuntu. These instructions have been used on a Ubuntu 22.04 server. These instructions are made available as a guideline. The author offers no support if it doesn't work.

## Pre-Installation

1. Verify that docker is not installed via snap. Docker that is insalled via snap does not have access to the entire file system as it is sandboxed, which won't work with CloudAtHome.
    
        sudo snap list

2. Uninstall snap docker if it is installed.

        sudo snap remove docker docker-compose

3. Install docker.io.

        sudo apt install docker.io docker-compose

4. Enable a non root user to use the docker command.

        sudo groupadd docker
        sudo usermod -aG docker username

5. Install, configure and enable the ufw firewall.

        sudo -s
        apt install ufw
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        ufw enable


## Installation

You will need the following information to complete the install:

    * A domain name
    * An email for the let's encrypt ssl certificate registration
    * SMTP host name, login user, port number, login user password, and email from address, so the blog and nextcloud can send administrator emails.
    * A root password and user password for blog and nextcloud databases. These can be the same password.

Installation of the vps is completely driven from the in home computer. See the README in the household directory for instructions to install the vps portion of CloudAtHome.


## Installation Notes

* When you purchase a vps server from a vps service provider they will provide you with a root password and the IP address of your server. You can ssh into your server with ssh root@IP_Address (eg. ssh root@114.78.43.2). To increase security you should do the following:

    * Create a non root user with sudo access on the vps server. I recommend that you do not use a persons name as the username, but generate a 12 (or more) character username with a password generator. Generate a user name with a mix of upper and lower case characters, letters only, no special characters. Hackers have dictionaries of peoples names that they use to try to log in to your ssh server. If it is really hard to guess a valid user name, their attempts are that much harder. When their ssh login attempts fail, they aren't told why, so they don't know that it is because of the user name being invalid.

            sudo adduser <username> --force-badname
            sudo usermod -aG sudo <username>

    * Generate a public/private ssh key pair, without a passphrase, on your home computer, and copy the public key to the vps server. It is wise to do this on at least two separate computers so that you have a backup method of access to the vps server. You can use [Windows WSL](https://learn.microsoft.com/en-us/windows/wsl/install) as your home computer ssh client.
    
            ssh-keygen -t ed25519
            ssh-copy-id <username>@IP_address

        * Verify you can login to your vps server without entering a password. It is very important you can login to your ssh server, from your home computer, without a password, before you make the ssh server configuration changes below.

                ssh <username>@IP_address

    * Make the following changes to the vps ssh server configuration and restart the ssh server.

                sudo nano /etc/ssh/sshd_config
                systemctl restart sshd

        These are the lines to change in sshd_config.

        * Disable root login.

                    PermitRootLogin no

        * Enable public key authentication.

                    PubkeyAuthentication yes

        * Decrease login grace time.

                    LoginGraceTime 20
            
        * Decrease maximum authentication tries.

                    MaxAuthTries 2

        * Disable password authentication.

                    PasswordAuthentication no

    * Optionally change the ssh server port number.

            ufw allow <sshport>/tcp comment "ssh"
            ufw reload
            sudo nano /etc/ssh/sshd_config

                Port <sshport> # change this line in sshd_config

            systemctl restart sshd

        * From now on, use the following command to login to vps with ssh.

                ssh -p <sshport> <username>@IP_address

        * Once you have tested that login on the new port number works, you can block the original ssh port access with ufw.

                ufw delete allow ssh
                ufw reload

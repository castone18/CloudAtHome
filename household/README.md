# CloudAtHome Local Installation

Follow this guideline to install the in home portion of CloudAtHome.

## Pre-Installation

1. Your first step is to set up Ubuntu, or some other debian derivative, on a server computer that will be always on in the home. You can use an old laptop or desktop for this purpose. If you use an old laptop/desktop, then I would recommend you replace the hard drive with an SSD drive so that there
are no moving parts in the computer and it will be less prone to failure. Do not put the server on wifi, connect it directly with an ethernet cable to your internet gateway from your ISP. There are many howto's on the Internet to show you how to do this.

2. Verify that docker is not installed via snap. Docker that is insalled via snap does not have access to the entire file system as it is sandboxed, which won't work with CloudAtHome.
    
        sudo snap list

3. Uninstall snap docker if it is installed.

        sudo snap remove docker docker-compose

4. Install docker.io.

        sudo apt install docker.io docker-compose


## Installation

You will need the following information to complete the install:

    * A domain name
    * An email for the let's encrypt ssl certificate registration
    * SMTP host name, login user, port number, login user password, and email from address, so the blog and nextcloud can send administrator emails.
    * A password for various databases, etc.
    * A ubuntu server in the home.
    * A vps server in the cloud.
    * VPS login credentials.


Installation is completed with the following steps. 

1. Clone this repository.

        git clone https://github.com/castone18/CloudAtHome.git

2. Enter install configuration data.

        cd CloudAtHome
        sudo ./bin/cloudAtHome install configure

3. Install vps components.

        sudo ./bin/cloudAtHome install vps

4. Install local components.

        sudo ./bin/cloudAtHome install local


## Post Installation

You need to configure wordpress and nextcloud. You can configure wordpress at https://www.example.com/wp-admin., where you replace example.com with your domain name. You can configure nextcloud at https://cloud.example.com:8443. You will likely need to consult the nextcloud documentation at https://docs.nextcloud.com and the wordpress documentation at https://make.wordpress.org/support/user-manual.

## Notes

If you backup your photos from your phone to nextcloud, the first upload will normally be a large amount of photos. You can generate all of the photo previews offline by using the following commands. The -u 33 provides the userid for the www-data user which is obtained in the first commmand. Generating previews offline will greatly improve performance when you view the photos folder in your browser. It can take quite some time to generate the previews.

                docker exec -it nextcloud-aio-nextcloud id -u www-data
                docker exec -it -u 33 nextcloud-aio-nextcloud ./occ app:install previewgenerator
                docker exec -it -u 33 nextcloud-aio-nextcloud ./occ files:scan-app-data
                docker exec -it -u 33 nextcloud-aio-nextcloud ./occ preview:generate-all --verbose
                docker exec -it -u 33 nextcloud-aio-nextcloud ./occ app:remove previewgenerator

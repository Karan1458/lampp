# LAMPP Stack - Docker Compose

Lampp stack made up with docker-compose. This project is created to handle the web development tasks on local.

### Things to Do

- [ ] PHPMyAdmin - Auto Configuration
- [ ] Slim Docker Containers
- [ ] Auto Discovery Selected Folder for Sites 
- [ ] Auto SSL sites
- [ ] PHP Version Selector


### Usage 
 - `./setup.sh build-start` - For Building Images and Start Docker
 - `./setup.sh start` - For starting docker images
 - `./setup.sh stop` - For stopping docker images
 - `./setup.sh destroy` - Removing all images and data
 - `./setup.sh add-site domain path` - Valid mount point can become domain. ( domain without any tld )
 - `./setup.sh remove-site domain` - removing the domain and it's config file ( domain without any tld )

 ### Instruction 
 Make sure to enable file sharing for the required directorys. 

 [![File Sharing - Docker](usage/file-sharing-docker.png)](https://docs.docker.com/desktop/synchronized-file-sharing/)

 

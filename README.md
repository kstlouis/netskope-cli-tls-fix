# What that thang do 

This script will:
- find local system certs and create a combined cert bundle for Netskope and AWS
- create (or update) `.zshrc` and `.bashrc` files to include env variables for common CLI tools to use the new cert bundle
- directly configure a tool if it's not possible to export an env var for it (such as npm, yarn, etc)

### For testing:
- save the script locally 
- run `chmod +x netskope-cli-tls-fix.sh` then `sudo ./netskope-cli-tls-fix.sh`
- if deployed via Jamf, it will always run as root, but `sudo` will be required if running locally

### Clean up .zshenv/.bash_profile
Previous versions of this script wrote to either `.bash_profile` or `.zshev`, instead of their respective `rc` files. You may want to remove the added sections or the entire file if you hadn't used it previously.


### For deployment via MDM:

- this script _should_ be service-agnostic. However, I have no experience with other MDMs besides Jamf.
# TODO

- list sources/credit. _something something great artists steal._
- actually test via Jamf policy deployment. Local testing isn't fully representative bc Jamf runs as root.
- re-learn how to use git, apparently. What are branches? 😅

# Thanks

This is mostly a horrible demon-child of Netskope community documentation and other git repo's for netskope tls inspection workarounds. 
- duduke's [ssl-configure-scripts](https://github.com/duduke/ssl-configure-scripts/tree/main)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception (deprecated)](https://docs.netskope.com/en/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception (forums discussion)](https://community.netskope.com/next-gen-swg-2/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception-7015)


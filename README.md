# How to use this

### For testing:
- save the script locally 
- run `chmod +x netskope-cli-tls-fix.sh`
- then `sudo ./netskope-cli-tls-fix.sh`

(if deployed via jamf, it will always run as root, but `sudo` is required if running locally)

Output:
- review stdout 
- Check `~/.zshenv` (or `~/.bash_profile"` for new items related to any installed tools 
- `configured_tools.sh` should also exist in the same dir and list all configuration changes applied

### For deployment via MDM:

- this script should be service-agnostic since it does not require any parameters ($4, etc, via Jamf). However, I have no experience with other MDMs. 
- Before deploying, comment out all lines related to `configured_tools.sh`. Useful for testing but otherwise just junk files.

# TODO

- list sources/credit. _something something great artists steal._
- actually test via Jamf policy deployment. "run as user" segments probably need review.
- clean up / comment out any tools known not to be used in our org. 
- re-learn how to use git, apparently.

# Inspiration

This is mostly a horrible demon-child of Netskope community documentation and other git repo's for netskope tls inspection workarounds. 
- duduke's [ssl-configure-scripts](https://github.com/duduke/ssl-configure-scripts/tree/main)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception (deprecated)](https://docs.netskope.com/en/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception](https://community.netskope.com/next-gen-swg-2/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception-7015)


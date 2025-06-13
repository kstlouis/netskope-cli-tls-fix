# What that thang do 

### For testing:
- save the script locally 
- run `chmod +x netskope-cli-tls-fix.sh` then `sudo ./netskope-cli-tls-fix.sh`
- you'll need the use an `.env` file or similar to pass the org info usually passed as Jamf script parameters

(if deployed via jamf, it will always run as root, but `sudo` will be required if running locally)

Output:
- review stdout 
- Check `~/.zshenv` (or `~/.bash_profile"` for new items related to any installed tools 
- `configured_tools.sh` should also exist in the same dir and list all configuration changes applied, unless it's commented out.

### For deployment via MDM:

- this script _should_ be service-agnostic, other than tweaking how the tenantName and orgKey are passed in. However, I have no experience with other MDMs. 
- Before deploying, comment out all lines related to `configured_tools.sh`. Useful for testing but otherwise just junk.

# TODO

- list sources/credit. _something something great artists steal._
- actually test via Jamf policy deployment. "run as user" segments probably need review.
- remove / comment out any tools known not to be used in our org. 
- re-learn how to use git, apparently 🙃

# Inspiration

This is mostly a horrible demon-child of Netskope community documentation and other git repo's for netskope tls inspection workarounds. 
- duduke's [ssl-configure-scripts](https://github.com/duduke/ssl-configure-scripts/tree/main)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception (deprecated)](https://docs.netskope.com/en/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception)
- [Configuring CLI-based Tools and Development Frameworks to work with Netskope SSL Interception (forums discussion)](https://community.netskope.com/next-gen-swg-2/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception-7015)


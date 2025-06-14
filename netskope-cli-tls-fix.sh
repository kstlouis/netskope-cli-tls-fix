#!/bin/bash

## This tool will try to detect common cli tools and will configure the Netskope SSL certificate bundle.

# Get the current console user

CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
echo "Current logged-in user: $CURRENT_USER"

get_shell(){
    # Get current user
    CURRENT_USER=$(stat -f "%Su" /dev/console)
    
    # Get that user's shell from the system directory service
    USER_SHELL=$(dscl . -read /Users/"$CURRENT_USER" UserShell | awk '{print $2}')
    echo "Shell used is $USER_SHELL"
    
    if [[ $USER_SHELL == *"bash"* ]]; then
        shell="/Users/$CURRENT_USER/.bash_profile"
    else
        shell="/Users/$CURRENT_USER/.zshenv"
    fi
    echo "Config file: $shell"

    # Ensure the shell config file exists before using it
    if [[ ! -f "$shell" ]]; then
    echo "# Created by get_shell script" > "$shell"
    fi
}
get_shell

mkdir -p /Users/Shared/Netskope
tenantName=$4
orgKey=$5
certDir="/Users/Shared/Netskope"
certName="nscacert_combined.pem"

status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null https://$tenantName/locallogin)

if [[ "$status_code" -ne "307" ]] ; then
  echo "Tenant Unreachable"
  exit 1
else
  echo "Tenant Reachable"
fi

# Function to create or update certificate bundle
create_cert_bundle() {
  echo "Creating cert bundle"
  curl -k "https://addon-$tenantName/config/ca/cert?orgkey=$orgKey" > $certDir/$certName
  curl -k "https://addon-$tenantName/config/org/cert?orgkey=$orgKey" >> $certDir/$certName
  curl -k -L "https://ccadb-public.secure.force.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites" >> $certDir/$certName
}

if [ -f "$certDir/$certName" ]; then
  echo "$certName already exists in $certDir."
  read -p "Recreate Certificate Bundle? (y/N) " -n 1 -r
  echo    
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    create_cert_bundle
  fi
else
  create_cert_bundle
fi



# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to configure a tool with the certificate bundle
configure_tool() {
  local tool_name=$1
  local env_var=$2
  local check_command=$3
  local post_command=$4

  echo
  if command_exists "$check_command"; then
    echo "$tool_name is installed"
    #$check_command --version. # this is noisy af, leave out unless needed
    if [[ -n "$env_var" ]]; then
      export_line="export $env_var=\"$certDir/$certName\""
      if [[ ${!env_var} == "$certDir/$certName" ]]; then
        echo "$tool_name already configured"
      elif grep -Fxq "$export_line" "$shell"; then
        echo "$tool_name already configured in $shell"
        source "$shell"
      else
        echo "$export_line" >> "$shell"
        echo "$tool_name configured"
        source "$shell"
      fi
    fi
    if [[ -n "$post_command" ]]; then
      eval $post_command
      echo "$post_command" >> configured_tools.sh
    fi
  else
    echo "$tool_name is not installed"
  fi
}

# This allows for later silent runs on other machines
> configured_tools.sh

# Configure tools
configure_tool "gam" "" "/Users/$CURRENT_USER/bin/gamadv-xtd3/gam" "/Users/$CURRENT_USER/bin/gamadv-xtd3/gam config cacerts_pem $certDir/$certName save"
configure_tool "Git" "GIT_SSL_CAPATH" "git" ""
configure_tool "OpenSSL" "SSL_CERT_FILE" "openssl" ""
configure_tool "cURL" "SSL_CERT_FILE" "curl" ""
configure_tool "Python Requests Library" "REQUESTS_CA_BUNDLE" "" ""
configure_tool "AWS CLI" "AWS_CA_BUNDLE" "awscli" ""
configure_tool "Google Cloud CLI" "" "gcloud" "gcloud config set core/custom_ca_certs_file $certDir/$certName"
configure_tool "NodeJS Package Manager (NPM)" "" "npm" "npm config set cafile $certDir/$certName"
configure_tool "NodeJS" "NODE_EXTRA_CA_CERTS" "node" ""
configure_tool "Ruby" "SSL_CERT_FILE" "ruby" ""
configure_tool "PHP Composer" "" "composer" "composer config --global cafile $certDir/$certName"
configure_tool "GoLang" "SSL_CERT_FILE" "go" ""
configure_tool "Azure CLI" "REQUESTS_CA_BUNDLE" "az" ""
configure_tool "Python PIP" "REQUESTS_CA_BUNDLE" "pip3" ""
configure_tool "Oracle Cloud CLI" "REQUESTS_CA_BUNDLE" "oci-cli" ""
configure_tool "Cargo Package Manager" "SSL_CERT_FILE" "cargo" ""
configure_tool "Yarn" "" "yarnpkg" "yarnpkg config set httpsCaFilePath $certDir/$certName"

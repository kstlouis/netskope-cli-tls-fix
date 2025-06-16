#!/bin/zsh

## This tool will try to detect common cli tools and will configure the Netskope SSL certificate bundle.

# Get the current console user
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
echo "Current logged-in user: $currentUser"

ZSHRC="/Users/$currentUser/.zshrc"
BASHRC="/Users/$currentUser/.bashrc"
mkdir -p "/Users/$currentUser/.netskope" # Create the folder if not there
finalCertPath="/Users/$currentUser/.netskope/netskope-CLI-cert-bundle.pem"
netskopeCertPath="/Users/$currentUser/.netskope/nscacert_combined.pem"
certFolderPath=$(dirname "$finalCertPath")
certFileName=$(basename "$finalCertPath")
awsHomeBrew="/opt/homebrew/bin/aws" # HomeBrew install
awsRelease="/usr/local/bin/aws" # AWS Official Release 
BLOCK_BEGIN="# >>> NETSKOPE CA BUNDLE ENV VARS >>>"
BLOCK_END="# <<< NETSKOPE CA BUNDLE ENV VARS <<<"


# What AWS should we use.
if [[ -x "$awsHomeBrew" ]]; then
    awsBinary="$awsHomeBrew"
    awsCertPath="/opt/homebrew/etc/ca-certificates/cert.pem"
elif [[ -x "$awsRelease" ]]; then
    awsBinary="$awsRelease"
    awsCertPath="/usr/local/bin/aws/awscli/botocore/cacert.pem"
else
    echo "AWS CLI not found. Skipping adding the AWS Cert Bundle"
    awsCertPath=""
fi

# Create Bundle of all System Root Certs
security find-certificate -a -p "/System/Library/Keychains/SystemRootCertificates.keychain" "/Library/Keychains/System.keychain" > "/tmp/nscacert_combined.pem"
cp "/tmp/nscacert_combined.pem" "${certFolderPath}"

if [[ -f "$netskopeCertPath" ]]; then
  echo "Netskope Combined Cert was created"
else
  echo "The Netskope Combined Cert was not Created. Exiting..."
   # ErrorDialog=$($dialogPath "${dialogOptions[@]}" \
     # --bannertitle "${holdingCompany} - Netskope CLI Bundle ERROR" \
     # --message "The was Error creating the Netskope combined certificate bundle.<br><br>Please contant Support for help." \
     # --button1text "Close" \
     # --json )
  exit 2
fi

# Create the Netskope and AWS Combined Bundle
echo "Netskope Certs: $netskopeCertPath"
if [ -f  "${awsCertPath}" ]; then
  echo "AWS Certs: $awsCertPath"
  echo "AWS CLI: $awsBinary"
  cat "${awsCertPath}" "${netskopeCertPath}" > "${finalCertPath}"
  echo "Netskope & AWS Combined Cert was created"
else
  cat "${netskopeCertPath}" > "${finalCertPath}"
  echo "Netskope Combined Cert was created"
fi 

echo "Combined Cert: ${finalCertPath}"

# Shell Settings to Add
NEW_BLOCK=$(cat <<EOF
$BLOCK_BEGIN
export REQUESTS_CA_BUNDLE='${finalCertPath}' # Python/AZURE CLI/Other Tools         
export AWS_CA_BUNDLE='${finalCertPath}' # AWS CLI
export SSL_CERT_FILE='${finalCertPath}' # OPENSSL
export NODE_EXTRA_CA_CERTS='${finalCertPath}' # NODE
export CURL_CA_BUNDLE='${finalCertPath}' # CURL
$BLOCK_END
EOF
)

touch "$ZSHRC" # Ensure .zshrc exists
touch "$BASHRC" # Ensure .BASHRC exists

# Remove old block if it exists for ZSHRC
if grep -q "$BLOCK_BEGIN" "$ZSHRC"; then
    echo "Found existing Netskope CA bundle block in ${ZSHRC}. Removing it..."
    # Use awk to remove the block between markers
    awk "/$BLOCK_BEGIN/{flag=1;next}/$BLOCK_END/{flag=0;next}!flag" "$ZSHRC" > "${ZSHRC}.tmp" && mv "${ZSHRC}.tmp" "$ZSHRC"
fi
# Append new block to .zshrc
echo -e "\n$NEW_BLOCK" >> "$ZSHRC"
echo "Updated Netskope cert bundle exports in $ZSHRC"
source "$HOME/.zshrc" # Load the ZShell File Now

# Remove old block if it exists for BASHRC
if grep -q "$BLOCK_BEGIN" "$BASHRC"; then
    echo "Found existing Netskope CA bundle block in ${BASHRC}. Removing it..."
    # Use awk to remove the block between markers
    awk "/$BLOCK_BEGIN/{flag=1;next}/$BLOCK_END/{flag=0;next}!flag" "$BASHRC" > "${BASHRC}.tmp" && mv "${BASHRC}.tmp" "$BASHRC"
fi
# Append new block to .BASHRC
echo -e "\n$NEW_BLOCK" >> "$BASHRC"
echo "Updated Netskope cert bundle exports in $BASHRC"

# Add Fix for older Bash Settings
line='[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"'
touch "/Users/${currentUser}/.bash_profile" # Ensure .bash_profile exists
grep -qxF "$line" "/Users/${currentUser}/.bash_profile" || echo -e "\n$line" >> "/Users/${currentUser}/.bash_profile"
source "$HOME/.bashrc" # Load the Bash File Now

export REQUESTS_CA_BUNDLE="${finalCertPath}" # Python/AZURE CLI/Other Tools         
export AWS_CA_BUNDLE="${finalCertPath}" # AWS CLI
export SSL_CERT_FILE="${finalCertPath}" # OPENSSL
export NODE_EXTRA_CA_CERTS="${finalCertPath}" # NODE
export CURL_CA_BUNDLE="${finalCertPath}" # CURL

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
    echo "$tool_name is not installed, ignoring"
  fi
}

configure_tool "NodeJS Package Manager (NPM)" "" "npm" "npm config set cafile ${finalCertPath}"

## Clean Up
if [[ -f "$netskopeCertPath" ]]; then
  rm -f "$netskopeCertPath"
fi
if [[ -f "/tmp/nscacert_combined.pem" ]]; then
  rm -f "/tmp/nscacert_combined.pem"
fi
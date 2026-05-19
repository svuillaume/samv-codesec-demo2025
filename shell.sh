#!/usr/bin/env bash
# demo_login_plain.sh
# Simple demo: compares entered username/password to hardcoded values.
# NOT secure — for demonstration only.

# Hardcoded demo credentials (example only)
EXPECTED_USER="demo"
EXPECTED_PASS="password123"

# Prompt user
read -p "Username: " USERNAME
read -s -p "Password: " PASSWORD
echo

if [[ "$USERNAME" == "$EXPECTED_USER" && "$PASSWORD" == "$EXPECTED_PASS" ]]; then
  echo "Login successful — welcome, $USERNAME!"
  # Put demo "protected" actions here
else
  echo "Login failed."
  exit 1
fi

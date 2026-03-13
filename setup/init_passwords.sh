#!/bin/bash
# ABOUTME: Creates the hidden passwords file on the network volume if it doesn't exist
# ABOUTME: Run once per fresh network volume setup

PASSWORDS_FILE="/workspace/.passwords.json"

if [ -f "$PASSWORDS_FILE" ]; then
    echo "Passwords file already exists at $PASSWORDS_FILE — skipping."
    exit 0
fi

cat > "$PASSWORDS_FILE" << 'EOF'
{
    "Razvan Matei": "X26hpT6dypy1ogVK",
    "Team 1": "AuC1uwkIs9mpO0t0",
    "Team 2": "sXHG0SM26nRmEuRW",
    "Team 3": "H21oOzDf3bBlxGfd",
    "Team 4": "AmtRY7PjdbLk6u8j",
    "Team 5": "CuVeTCb13SasrRlc",
    "Team 6": "4vnPtzNenCocBMax",
    "Team 7": "uWR8CplPHr04fLpO",
    "Team 8": "Kez23Dq1SjnfnF2d"
}
EOF

chmod 600 "$PASSWORDS_FILE"
echo "Passwords file created at $PASSWORDS_FILE"

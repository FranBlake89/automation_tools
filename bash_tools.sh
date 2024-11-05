#!/bin/bash

# Checking Connection to Internet
checking_connection(){
	URL="https://jsonplaceholder.typicode.com/posts/10"
	RESPONSE=$(curl --head --silent --output /dev/null --write-out "%{http_code}" "$URL") # Using CURL method I get just the status codes

	if [[ $RESPONSE -eq 200 ]]; then  # Know if I got 200 code
		echo "☺︎ Connection Established!"
	else
		echo "☹︎ Error: status code $RESPONSE"
		exit 1 # exit app
	fi
}

installing_dependencies(){
	# List of dependencies
	dependencies=( #list of dependencies 
		"jq"
		"curl"
		"httpie"
	)

	echo "Welcome to my Bash Tools!"
	echo "We are going to check if all required dependencies are installed."

	# Checking OS
	if [[ $(uname) == "Linux" ]]; then # getting OS name and cheking if it Linux
		echo "🐧 Running on Linux"
	elif [[ $(uname) == "Darwin" ]]; then # getting OS name and cheking if it macos
		echo "🍎 Running on macOS"
	else
		echo "Unsupported operating system"
		exit 1
	fi


	checking_connection # trigger to check connection

	# Function to check if a command exists
	check_command(){
		command -v "$1" >/dev/null 2>&1 # version of the input 
	}

	# Functions to install a package depending on OS
	install_debian(){
		echo "Installing $1 on Debian-based system..."
		sudo apt-get install -y "$1"
	}

	install_fedora(){
		echo "Installing $1 on Fedora-based system..."
		sudo dnf install -y "$1"
	}

	install_macos(){
		echo "Installing $1 on macOS..."
		brew install "$1"
	}

	# Installation and Validation
	validate_installation(){
		if check_command "$1"; then
			echo "✓ $1 is installed"
		else
			echo "🅧 $1 is not installed"
			if [[ $(uname) == "Linux" ]]; then
				if [[ -x /usr/bin/apt-get ]]; then
					install_debian "$1"
				elif [[ -x /usr/bin/dnf ]]; then
					install_fedora "$1"
				else
					echo "Unsupported package manager. Please install $1 manually."
					exit 1
				fi
			elif [[ $(uname) == "Darwin" ]]; then
				# Ensure Homebrew is installed
				if ! command -v brew &> /dev/null; then
					echo "Homebrew not found. Installing Homebrew..."
					/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
				else
					echo "✓ Homebrew already installed"
				fi

				install_macos "$1"
				# Force reload the shell to update the path, if necessary
				eval "$(/opt/homebrew/bin/brew shellenv)"
			fi

			# Check again if the installation succeeded
			if check_command "$1"; then
				echo "✓ $1 installation successful"
			else
				echo "🅧 $1 could not be installed. Please check manually."
				exit 1
			fi
		fi
	}

	# Iterate through dependencies and validate
	for dependency in "${dependencies[@]}"; do
		validate_installation "$dependency"
	done
	echo -e "\n\n-----"
	echo " ✓✓ All dependencies are checked and installed as needed!"
	echo -e "	You can use now the tools\n"
}

# OpenFactura API --> need token to be dinamic
test_openfactura(){
	http --body GET 'https://dev-api.haulmer.com/v2/dte/taxpayer/76795561-8' apikey:928e15a2d14d4a6292345f04960f4bd3 | jq \
		'{
			"Razon Social": .razonSocial,
			"RUT": .rut,
			"Email": .email,
			"Telefono": .telefono,
			"Direccion": .direccion,
			"Comuna": .comuna
		}'
}

# API from Max Programadores Chile
api_max_programadores_chile(){
	rut=$1
	http --body --follow POST $API_RUT \
RUT=$rut | jq
}

searching_by_rut() {
    read -p "Enter RUT (ej.: 12345678-0): " rut
    
    # regex pattern for validating RUT
    if [[ $rut =~ ^[0-9]{7,8}-[0-9kK]$ ]]; then
        # Call the function to handle valid RUT
        api_max_programadores_chile "$rut"
    else
        echo "Invalid format"
        echo "$rut"
    fi
}

google_apps_get() {
	read -p "Enter your name: " name
	read -p "Enter your age: " age
	http --body --follow GET "$URL_GOOGLE_APPS?name=$name&age=$age" | jq
}

google_apps_post(){
	read -p "Enter your name: " name
	read -p "Enter your age: " age
	http --body --follow GET "$URL_GOOGLE_APPS_POST?name=$name&age=$age" | jq
}

show_menu() {
	echo -e "\n"
	echo "Please select an option:"
	echo "  1) Check and install dependencies"
	echo "  2) Check internet connection"
	echo "  3) Test Open Factura API (Sandbox)"
	echo "  4) Searching by RUT with Programadores Chile API"
	echo "  5) Google Apps Script GET Method"
	echo "  6) Google Apps Script POST Method"
	echo "  q) Exit"
}

# Function to read user choice and execute selected option
read_choice() {
	read -p "Enter your choice [1-6]: " choice
	case $choice in
		1)
			installing_dependencies
			;;
		2)
			checking_connection
			;;
		3)
			test_openfactura
			;;
		4)
			searching_by_rut
			;;
		5)
			google_apps_get
			;;
		6)
			google_apps_post
			;;
		q)
			echo "Exiting..."
			exit 0
			;;
		*)
			echo "Invalid option. Please try again."
			;;
	esac
}

# Show system information
display_system_info() {
	echo "Running on: $(uname -n)"
	echo "User: $(whoami)"
	echo "Home Directory: $HOME"
}

# Checking ENV file
if [ -f .env ]; then 
    source .env # "Charging" file and variables from .env
else
    echo ".env file not found!"
fi # end if


# Function to show menu options
echo -e "\n"
echo "Welcome to the Bash Tools Menu!"
display_system_info


# Main loop to show menu repeatedly
while true; do
	show_menu
	read_choice
done
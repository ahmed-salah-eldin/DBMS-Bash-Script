RED='\033[31m'
CYAN='\033[36m'
GREEN='\033[32m'
NC='\033[0m'
export RED CYAN GREEN NC
PS3="Enter your choice: "
function createDB
{
	if [ -d databases/$1 ]
	then
		echo -e "${RED}Database $1 already exists${NC}"
	else
		mkdir -p databases/$1/{meta,tables,tmp}
		touch databases/$1/tmp/tmp
		echo -e "${GREEN}Database $1 created successfully${NC}"
	fi
}

function listDBs
{	
	echo -e "${CYAN}Current Databases:${NC}"
	dbList=`ls -1 databases`
	if [[ $dbList == "" ]]
	then
		echo -e "${RED}You Currently Have No Databases${NC}"
	else
		echo -e "${CYAN}$dbList${NC}"
	fi
}

function dropDB
{
        if [ -d databases/$1 ]
        then
                rm -r databases/$1
		echo -e "${GREEN}Database $1 successfully deleted${NC}"
        else
                echo -e "${RED}Database $1 does not exist${NC}"
        fi
}

function connectDB
{
	if [ -d databases/$1 ]
	then
		echo -e "${GREEN}successfuly connected to $1${NC}"
		db=$1
		export db
		./connect.sh
	else
		echo -e "${RED}Database $1 does not exist${NC}" 
	fi
}

if [ ! -d databases ]
then
	mkdir databases
fi
while [ 1 ]
do
	select choice in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
	do
		case $REPLY in
		1)	listDBs
			read -p "Enter Database Name To Create: " dbNameCreate
			createDB $dbNameCreate
			break;;
		2)
			listDBs
			break;;
		3)	
			listDBs
			if [[ $dbList != "" ]]
			then
				read -p "Enter Database Name To Connect: " dbNameCon
				connectDB $dbNameCon
			fi
			break;;	
		4)	
			listDBs
			if [[ $dbList != "" ]]
			then
				read -p "Enter Database Name To Delete: " dbNameDel 
				dropDB $dbNameDel
			fi
			break;;
		5)
			break 2;;
		esac
	done	
done

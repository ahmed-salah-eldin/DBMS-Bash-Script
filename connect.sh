PS3="$db: "
typeset -i numColumns
function createTB
{
	if [ -f tables/$1 ]
	then
		echo -e "${RED}Table $1 Already Exists${NC}"
	else
		touch meta/$1
		touch tables/$1
		read -p "Enter Number Of Columns: " numColumns
		read -p "Enter The Primary Key Name: " primaryKey
		echo $primaryKey >> meta/$1
		while [[ $numColumns > 1 ]]
		do
			read -p "Enter The Next Column Name: " columnName
			echo $columnName >> meta/$1
			numColumns=$numColumns-1
		done	
		echo -e "${GREEN}Table $1 created successfilly${NC}"
	fi
}

function listTBs
{
	echo -e "${CYAN}Current Tables:${NC}"
	tbList=`ls -1 tables`
	if [[ $tbList == "" ]]
	then
		echo -e "${RED}You Currently Have No Tables${NC}"

	else
		echo -e "${CYAN}$tbList${NC}"
	fi
}

function insertTB
{
	columnsData=""
	if [ -f tables/$1 ]
	then
		columnsList=`cat meta/$1`
		for column in $columnsList
		do
			read -p "Enter $column Data: " columnData
			if [[ $columnsData == "" ]]
			then
				if [[ $columnData == "" ]]
				then
					echo -e "${RED}ID can not be null${NC}"
					return
				fi
				if [ `cut -d, -f1 tables/$1|grep $columnData` ]
				then
					echo -e "${RED}Same Primary Key Data Exists${NC}"
					return
				else
					columnsData="$columnData"
				fi
			else
				columnsData="$columnsData,$columnData"	
			fi
		done
		echo "$columnsData" >> tables/$1
		echo -e "${GREEN}Data Inserted Successfully${NC}"
	else
		echo -e "${RED}Table $1 does not exist${NC}"
	fi
}

function dropTB
{
	if [ -f tables/$1 ]
	then
		rm tables/$1
		rm meta/$1
		echo -e "${GREEN}Table $1 Dropped Successfully${NC}"
	else
		echo -e "${RED}Table $1 does not exist${NC}"
	fi
}


function deleteRow
{	
	read -p "Enter Table Name: " tbNameDelRow
	if [ -f tables/$tbNameDelRow ]
	then
		read -p "Enter Primary Key: " primaryKeyDel	
		awk -v primary=$primaryKeyDel 'BEGIN{FS=","}{if ($1!=primary) print $0 >> "tmp/tmp"
		else print "\033[32mRow Successfully Deleted\033[0m"}' tables/$tbNameDelRow
		cp tmp/tmp tables/$tbNameDelRow
		echo -n "" > tmp/tmp
	else
		echo -e "${RED}Table $tbNameDelRow does not exist${NC}"
	fi 
}

function selectRow
{
	read -p "Enter Table Name: " tbNameSelRow
	if [ -f tables/$tbNameSelRow ]
	then
		read -p "Enter Primary Key: " primaryKeySel
		colList=`cat meta/$tbNameSelRow`
		for col in $colList
		do
			echo -n -e  "${CYAN}$col\t\t${NC}"
		done
		echo ""
		awk -v primary=$primaryKeySel 'BEGIN{FS=","}{if ($1==primary) 
			for (i=1;i<=NF;i++) printf "\033[36m"$i"\t\t"}END{print "\033[0m"}' tables/$tbNameSelRow
	else
		echo -e "${RED}Table $tbNameSelRow does not exist${NC}"
	fi

}

cd databases/$db
while [ 1 ]
do
	select choice in "Create Table" "List Tables" "Drop Table" "Insert" "Select" "Delete" "Main Menu"
	do
		case $REPLY in
		1)	
			listTBs	
			read -p "Enter Table Name To Create: " tbToCreate
			createTB $tbToCreate
			break;;
		2)	
			listTBs	
			break;;
		3)	
			listTBs
			if [[ $tbList != "" ]]
			then
				read -p "Enter Table Name To Drop: " tbToDrop
				dropTB $tbToDrop
			fi	
			break;;
		4)	
			listTBs
			if [[ $tbList != "" ]]
			then
				read -p "Enter Table Name To Insert: " tbNameIns	
				insertTB $tbNameIns
			fi
			break;;
		5)
			listTBs
			if [[ $tbList != "" ]]
			then
				selectRow
			fi	
			break;;
		6)	
			listTBs
			if [[ $tbList != "" ]]
			then
				deleteRow
			fi
			break;;
		7)
			break 2;;
		esac
	done
done

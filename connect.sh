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
		isPrimaryKey=1
		while [[ $numColumns > 0 ]]
		do
			if [[ $isPrimaryKey == "1" ]]
			then
				echo -n "Enter The Primary Key Name: "
				isPrimaryKey=0
			else
				echo -n "Enter The Next Column Name: "
			fi
		
			read columnName
			PS3="Select Data Type: "
			select choice in "String" "Digit"
			do
				case $REPLY in
				1) 
					columnType="String"
					break;;
				2)
					columnType="Digit"
					break;;
				*)
					columnType="String"
					;;
				esac
			done
			echo "$columnName,$columnType" >> meta/$1
			numColumns=$numColumns-1
		done	
		echo -e "${GREEN}Table $1 created successfully${NC}"
		PS3="$db: "
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

	read -p "Enter Table Name To Insert: " tbNameIns		
	if [ -f tables/$tbNameIns ]
	then
		read -p "Enter Primary Key Data: " primaryKeyData
		if [[ $primaryKeyData == "" ]]
		then
			echo -e "${RED}ID can not be null${NC}"
			return
		fi
		if [ `cut -d, -f1 tables/$tbNameIns|grep $primaryKeyData` ]
		then
			echo -e "${RED}Same Primary Key Data Exists${NC}"
			return
		fi
		awk -v tableName=$tbNameIns -v primary=$primaryKeyData 'BEGIN{FS=","; columnsData=primary; errflag=0;}
		{	
			if (NR == 1){
			columnData=primary
		}	
		else{
			print "Enter "$1" Data with type "$2;
			getline columnData < "/dev/stdin";
		}
		if ($2 == "String" && columnData !~ /[A-Za-z]+[0-9]*/) {
			print "\033[31mInvalid Data Type expected String\033[0m";
			errflag=1;
			exit 1;
		}  
		if ($2 == "Digit" && columnData !~ /[0-9]+/){
			print "\033[31mInvalid Data Type expected Digit\033[0m";
			errflag=1;
			exit 1;
		}
		if (NR > 1){	
		columnsData=columnsData","columnData;
		}
		}
		END{if (errflag== 0){
		print columnsData >> "tables/"tableName;
		print "\033[32mRow Inserted Successfully\033[0m";
		}
		}' meta/$tbNameIns	
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
		colList=`cut -d, -f1 meta/$tbNameSelRow`
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
				#read -p "Enter Table Name To Insert: " tbNameIns	
				insertTB
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

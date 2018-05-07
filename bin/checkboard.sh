#! /usr/bin/env bash


 # Sample
#
#  ---------------
#  |X X X X X X X|
#  | X X X X X X |

chequered_board() {
	local size=$1 c="X "$'\n'"-|"
	for ((cell=1, row=1, pos=3, oldrow=1; cell<1+(size+2)**2+size+2;
	      pos =  ++cell % 2 == 0 ?  1:0,
	      pos =  (size+1) % 2 == 0 && row % 2 == 0 ?  pos^1:pos,
	      pos =  ( cell % ( (size+1+2)*oldrow+1 ) == 0
	               || cell % ( (size+1+2)*oldrow+size+2 ) == 0
	             ) ?  4:pos,
 	      pos =  row==1 || row == (size+2) ?  3:pos,
	      cell % (size+1+2) == 0 && (pos = 2) && (oldrow=row) && row++
	    )) {
		       echo -n "${c:$pos:1}"
	       }
}

chequered_board 3
chequered_board 8
chequered_board 15


chequered_board_simplified() {

	local size=$1
	local chars="X "$'\n'"-|"
	local cell=1
	local row=1
	local pos=3
	local oldrow=1
	local total_cells_to_print=$((1+(size+2)**2+size+2))

	for ((cell=1, cell<total_cells_to_print; cell++))
	{
		if [ $(( ++cell % 2 )) -eq 0 ]; then
			pos=1
		else
			pos=2
		fi

		if [ $(( (size+1) % 2  )) -eq 0 ] && [ $(())]
		pos=$(( (size+1) % 2 == 0 && row % 2 == 0 ?  pos^1:pos ))
		pos =  ( cell % ( (size+1+2)*oldrow+1 ) == 0
			|| cell % ( (size+1+2)*oldrow+size+2 ) == 0
			) ?  4:pos,
		pos =  row==1 || row == (size+2) ?  3:pos,
		cell % (size+1+2) == 0 && (pos = 2) && (oldrow=row) && row++
		echo -n "${c:$pos:1}"
	}

}
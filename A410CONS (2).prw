#INCLUDE "PROTHEUS.CH"

User Function A410CONS()

Local aButtons:={}

	SetKey( VK_F6, { || U_xCompSc6()} )
	
	aAdd(aButtons, {'Grade Avacy' ,{|| u_xCompSc6()} ,"Grade Avacy"})

Return(aButtons)



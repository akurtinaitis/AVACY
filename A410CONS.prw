#INCLUDE "PROTHEUS.CH"

// Fontaneli mexeu
User Function A410CONS()
 
Local aButtons:={}

	SetKey( VK_F6, { || U_xCompSc6()} )
	
	aAdd(aButtons, {'Grade de Produtos AVACY' ,{|| u_xCompSc6()} ,"Grade de Produtos AVACY"})
	aAdd(aButtons, {'Consultar Estoque AVACY' ,{|| U_Avacy04()} ,"Consultar Estoque AVACY"})
	
Return(aButtons)



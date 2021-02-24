#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 
  
//------------------------------------------------------------------- 
/*/{Protheus.doc} Avacy04 
Consulta Estoque Produtos x Grade 
 
@author Andr? Brito 
@since 18/07/2019 
@version P12 
/*/ 
//------------------------------------------------------------------- 
 
User Function Avacy04() 
 
	Local aArea    := GetArea() 
	Local oDlg 
	Local nRadio   := 2 
	Local nOpca    := 1 
 
	Private oRadio    
 
	While nOpca == 1 
 
		DEFINE MSDIALOG oDlg FROM  94,1 TO 300,293 TITLE "Painel de Consulta Estoque" PIXEL  
 
		@ 05,10 Say "Consulta Estoque por: " SIZE 150,7 OF oDlg PIXEL   
 
		@ 17,07 TO 82, 140 OF oDlg  PIXEL 
 
		@ 25,10 Radio oRadio VAR nRadio ITEMS "Produto","Grade" SIZE 110,10 OF oDlg PIXEL // ,"EAN14" 
 
		DEFINE SBUTTON FROM 85,115 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End()) 
		 
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso 
		//	para saida com ESC 
 
		If nOpca == 1 
			If nRadio == 1 
				XCONPRO()//Consulta por Produto 
			ElseIf nRadio == 2 
				XCONGRD() //Consulta por GTIN14	 
			EndIf 
		EndIf 
 
	EndDo 
 
	RestArea(aArea) 
 
Return  
 
//------------------------------------------------------------------- 
/*/{Protheus.doc} XCONPRO 
Consulta por produto 
 
@author Andr? Brito 
@since 18/07/2019 
@version P12 
/*/ 
//------------------------------------------------------------------- 
 
Static Function XCONPRO() 
 
	Local aArea     := GetArea()  
	Local aPWiz     := {} 
	Local aRetWiz   := {} 
	Local cProduto  := "" 
	Local nOpt      := 1 
	Local aCopy     := aClone(aRotina) 
	 
	aRotina := {} 
	 
	aAdd(aPWiz,{ 1,"Digite o c?digo PRODUTO: "  ,Space(15) ,"","","SB1","", ,.T.}) 
	 
	aAdd(aRetWiz,Space(15)) 
 
	ParamBox(aPWiz,"Consulta Estoque por Produto",@aRetWiz,,,,,,,,.T.,.T.)  
	 
	cProduto := Alltrim(aRetWiz[1]) 
 
	U_Avacy05(cProduto, nOpt) 
	 
	aRotina := aClone(aCopy) 
	 
	RestArea(aArea) 
 
Return 
 
//------------------------------------------------------------------- 
/*/{Protheus.doc} XCONGRD 
Consulta por c?digo GTIN14 
 
@author Andr? Brito 
@since 18/07/2019 
@version P12 
/*/ 
//------------------------------------------------------------------- 
 
Static Function XCONGRD() 
 
	Local aArea     := GetArea()  
	Local aPWiz     := {} 
	Local aRetWiz   := {} 
	Local cGrade   := "" 
	Local nOpt      := 2 
 
	aAdd(aPWiz,{ 1,"Digite o c?digo GRADE: "  ,Space(14) ,"","","","", ,.T.}) 
	 
	aAdd(aRetWiz,Space(14)) 
 
	ParamBox(aPWiz,"Consulta Estoque por C?digo GRADE",@aRetWiz,,,,,,,,.T.,.T.)  
	 
	cGrade := Alltrim(aRetWiz[1]) 
	 
	U_Avacy05(cGrade, nOpt) 
 
	RestArea(aArea) 
 
Return
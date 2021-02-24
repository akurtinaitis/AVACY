#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Avacy04
Consulta Estoque Produtos x Grade

@author André Brito
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
		
		
		// Quando escolhemos a Opcao 1
		If nOpca == 1
			If nRadio == 1
				XCONPRO()//Consulta por Produto
			ElseIf nRadio == 2
				XCONGRD() //Consulta por GTIN14	
			ElseIf nRadio == 3
				// Futuro (Fazendo nada agora)
			EndIf
		EndIf

	EndDo

	RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} XCONPRO
Consulta por produto

@author André Brito
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
	
	aAdd(aPWiz,{ 1,"Digite o código PRODUTO: "  ,Space(15) ,"","","SB1","", ,.T.})
	
	aAdd(aRetWiz,Space(15))

	ParamBox(aPWiz,"Consulta Estoque por Produto",@aRetWiz,,,,,,,,.T.,.T.) 
	
	cProduto := Alltrim(aRetWiz[1])

	U_Avacy05(cProduto, nOpt)
	
	aRotina := aClone(aCopy)
	
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XCONGRD
Consulta por código GTIN14

@author André Brito
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

	aAdd(aPWiz,{ 1,"Digite o código GRADE: "  ,Space(14) ,"","","","", ,.T.})
	
	aAdd(aRetWiz,Space(14))

	ParamBox(aPWiz,"Consulta Estoque por Código GRADE",@aRetWiz,,,,,,,,.T.,.T.) 
	
	cGrade := Alltrim(aRetWiz[1])
	
	U_Avacy05(cGrade, nOpt)

	RestArea(aArea)

Return
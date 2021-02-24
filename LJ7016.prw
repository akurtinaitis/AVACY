#include 'protheus.ch'

Static aCopy    := {}

User Function LJ7016(cSoma)

Local _aDados  := {}
Local nAtalho  := Paramixb[2]
Local aAtalho1  := {}
Local aAtalho2  := {}
Local cSomcx  := ""
Local xOpcao   := ""

Default cSoma  := "000"

If cSoma == "000" .And. xOpcao != "3"
	cSoma := BuscaSoma(SL1->L1_NUM)
	If Empty(cSoma)
		cSoma := "000"
	EndIf
EndIf

cSomcx := cSoma

nAtalho++
aAtalho1:= Lj7Atalho(nAtalho) 

nAtalho++
aAtalho2:= Lj7Atalho(nAtalho) 

AAdd(_aDados, {"Grade de Produtos AVACY" , "Grade de Produtos AVACY" , "RELATORIO", { || U_xPreGra(cSomcx) }, .T., .T., 4, aAtalho1} )
AAdd(_aDados, {"Consultar Estoque AVACY" , "Consultar Estoque AVACY" , "PEDIDO", { || U_Avacy04() }, .T., .T., 4, aAtalho2 } ) 

Return(_aDados)

/////////////////////////////////////////////
User Function xPreGra(cSoma)
 
Local aPWiz       := {}
Local aRetWiz     := {}
Local cCodGrd     := {}
Local cQtd        := ""
Local nQtd        := 0
Local aArea       := GetArea()
Local lProd       := .T.
Local lApresenta  := .T. 
Local cNomeUser   := Alltrim(UsrRetName(__CUSERID))
Local xOpcao      := ""
local cCliente    := M->LQ_cliente

DbSelectArea("SA1")
DbSeek(xFilial("SA1") + cCliente)

if EMPTY(SA1->A1_Tabela)
	    MsgInfo("Cliente sem tabela de Preço, a tabela -  001 - será atribuida nesta venda!","Sem Tabela!")
	    cTabela := "001"		
else
	   cTabela := SA1->A1_Tabela		
Endif 

If cSoma == "000" .And. xOpcao != "3"
	cSoma := BuscaSoma(SL1->L1_NUM)
	If Empty(cSoma)
		cSoma := "000"
	EndIf
EndIf

aAdd(aPWiz,{ 1,"Selecione a grade: "   ,Space(14) ,"","","Z01P","", ,.T.})
aAdd(aPWiz,{ 1,"Quantidade de grades: ",Space(6) ,"","","","", ,.T.})

aAdd(aRetWiz,Space(14))
aAdd(aRetWiz,Space(6))

If Empty(aCols[1][2])
	aCopy := aCols
	aCols := {}
EndIf

If Len(aCols)>1
	aCopy := aCols
EndIf

lApresenta := Parambox(aPWiz,"Seleção de Grade - Avacy",@aRetWiz,,,,,,) 

	If lApresenta
`
		cCodGrd   := Alltrim(aRetWiz[1])
		cQtd      := Alltrim(aRetWiz[2])
		nQtd      := Val(cQtd)
		
		lProd := U_xValGrd(cCodGrd)
		
		If !lProd
			MsgInfo("Grade inexistente ou Código incorreto!","Grade não existe")
			Return
		EndIf		
		
		If nQtd <= 0
			MsgInfo("O campo quantidade deve ser maior que zero!","Quantidade inválida!")
			Return
		EndIf

		RptStatus({|| xDigiLoja(cTabela,cCodGrd,cQtd,nQtd,cSoma)}, "Aguarde...", "Inserindo produtos...")
		
	endif
       
Return

/////////////////////////////////////////////
Static Function xDigiLoja(cTabela,cCodGrd,cQtd,nQtd,cSoma)

Local cAliAux     := GetNextAlias()
Local aArea       := GetArea() 
Local cQuery      := ""
Local nLinha      := 0
Local nAcols      := 0
Local ny          := 0
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_ITEM"})
Local nPosProd    := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRODUTO"})
Local nPosQuant   := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_QUANT"})
Local nPosVrUnit  := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VRUNIT"})
Local nPosDescri  := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESCRI"})
Local nPosVlrItem := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})
Local nPosUm      := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_UM"})
Local nPosGrade   := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_XGRADE"})
Local nPosxQtd    := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_XQTD"})
Local nPosxPeso   := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_XPESO"})
Local nPosxConf   := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_XCONF"})
Local nPosCaixa   := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_XCAIXA"})
Local nPosLote    := aScan(aHeaderDet,{|x| AllTrim(x[2]) == "LR_LOTECTL"})
Local nPosArm     := aScan(aHeaderDet,{|x| AllTrim(x[2]) == "LR_LOCAL"})

cQuery := "SELECT R_E_C_N_O_, * FROM "
cQuery += RetSqlName("Z02") + " Z02 "
cQuery += " WHERE "
cQuery += " Z02_CODGRD = '" + cCodGrd + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
	
nAcols := Len(aCols)

n := Len(aCols)

cSoma := Soma1(cSoma)

Do While (cAliAux)->(!Eof())
	
	nLinha := Len(aCols)+1
	
	Aadd(aCols,Array(Len(aHeader)+1))

	For ny := 1 To Len(aHeader)
		aCols[nLinha][ny] := aCopy[1][ny]
	Next

	aCols[nLinha][nPosItem]     := STRZERO(nLinha, 2, 0)
	aCols[nLinha][nPosProd]     := (cAliAux)->Z02_COD
	aCols[nLinha][nPosDescri]   := xBusDes((cAliAux)->Z02_COD)
	aCols[nLinha][nPosQuant]    := nQtd * Val((cAliAux)->Z02_QTD)
	aCols[nLinha][nPosVrUnit]   := xBusPre(cTabela, (cAliAux)->Z02_COD)
	aCols[nLinha][nPosVlrItem]  := xValItem(cTabela,(cAliAux)->Z02_COD, (cAliAux)->Z02_QTD, cQtd)
	aCols[nLinha][nPosUm]       := xSeaUni((cAliAux)->Z02_COD, cQtd)
	aCols[nLinha][nPosGrade]    := Alltrim(cCodGrd)
	aCols[nLinha][nPosxQtd]     := Alltrim(cQtd)
	aCols[nLinha][nPosxPeso]    := xBusPeso((cAliAux)->Z02_COD)
	aCols[nLinha][nPosCaixa]    := cSoma     

	n := n + 1

	Lj7Detalhe() 

	aColsDet[nLinha][nPosArm]  := "01"
	aColsDet[nLinha][nPosLote] := Alltrim(cCodGrd)

	(cAliAux)->(DbSkip())
		
EndDo

//Refaz Detalhes 
Lj7Detalhe() 
Lj7T_SubTotal( 2, 0) 
      
// Soma aCols nao deletados 
For nX := 1 To LEN(aCols) 
    If !aCols[nX,len(aHeader)+1] 
       If MaFisFound("IT",nX) .And. !MaFisRet(nX,"IT_DELETED") 
       	Lj7T_SubTotal( 2, ( Lj7T_SubTotal(2) + MaFisRet(nX, "IT_TOTAL") )) 
       EndIf 
    EndIf 
Next nX 
      
// Atualiza Rodapes com Totais 
Lj7T_Total(2,Lj7T_SubTot(2) - Lj7T_DescV(2))

Eval(bRefresh)

RestArea(aArea)

U_xPreGra(cSoma)

Return 

/////////////////////////////////////////////
Static Function xBusDes( cCod )

Local aArea     := GetArea() 
Local cDescri   := ""

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
cDescri := Alltrim(SB1->B1_DESC)

RestArea( aArea )

Return cDescri

/////////////////////////////////////////////
Static Function xBusPre(cTabela, cCod )

Local aArea       := GetArea() 
Local nPreco      := ""

DbSelectArea("DA1")
DbSetOrder(1) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
DbSeek(xFilial("DA1") + cTabela + cCod)
nPreco := DA1->DA1_PRCVEN
RestArea( aArea )

Return nPreco

/////////////////////////////////////////////
Static Function xValItem( cTabela,cCod, nQuanti, cQtd )

Local aArea      := GetArea() 
Local nValor     := 0
Local nQtdIt     := 0
Local nVlr       := 0

nQuanti := Val(nQuanti)

DbSelectArea("DA1")
DbSeek(xFilial("DA1") + cTabela + cCod)
nValor := DA1->DA1_PRCVEN * nQuanti  

nQtdIt := Val(cQtd)
nVlr   := nQtdIt * nValor

RestArea( aArea )

Return nVlr

/////////////////////////////////////////////
Static Function xSeaUni( cCod, cQtd )

Local aArea      := GetArea() 
Local cUnidade   := ""

DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cCod)
	cUnidade := Alltrim(SB1->B1_UM)
Else
	cUnidade := ""
EndIf

RestArea( aArea )

Return cUnidade

/////////////////////////////////////////////
User Function xValGrd(cCodGrd)

Local aArea      := GetArea()
Local lRet       := .T.

cCodGrd  := Alltrim(cCodGrd)

DbSelectArea("Z01")
Z01->(DbSetOrder(1))

If !DbSeek( xFilial("Z01") + cCodGrd )
	//MsgInfo("Código de grade inexistente","Código de grade")
	lRet := .F.
EndIf

RestArea( aArea )

Return lRet

/////////////////////////////////////////////
Static Function xBusPeso( cCod )

Local aArea       := GetArea() 
Local nPeso       := 0

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
nPeso := SB1->B1_PESO

RestArea( aArea )

Return nPeso

/////////////////////////////////////////////
Static Function BuscaSoma(cOrcamento)

Local aArea     := GetArea() 
Local cAliAux   := GetNextAlias()
Local cQuery    := ""
Local cSoma     := ""

cQuery := "SELECT MAX (L2_XCAIXA) SOMA FROM "
cQuery += RetSqlName("SL2") + " SL2 "
cQuery += " WHERE "
cQuery += " L2_NUM = '" + cOrcamento + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cSoma := (cAliAux)->SOMA

RestArea( aArea )

Return cSoma
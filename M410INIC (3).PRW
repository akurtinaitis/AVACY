#INCLUDE 'PROTHEUS.CH'

User Function M410INIC()

Local aArea      := GetArea() 

//SetKey( VK_F6, { || U_xCompSc6()} ) REMOVIDO FONTANELLI

RestArea( aArea )

Return 

//-----------------------------------------------------------------------------------------------------------------------
User Function xCompSc6()

Local aPWiz       := {}
Local aRetWiz     := {}
Local cCodGrd     := {}
Local cAliAux     := GetNextAlias()
Local cQuery      := ""
Local nLinha      := 0
Local nAcols      := 0
Local cQtd        := ""
Local nQtd        := 0
Local aArea       := GetArea()
Local aCopy       := {}
Local cTes        := SuperGetMV("MV_XTES",.T.,"512")
Local lCont       := .T.
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
Local nPosProd    := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPosDescri  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_DESCRI"})
Local nPosUni     := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_UM"})
Local nPosQtdVen  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
Local nPosPrcVen  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
Local nPosValor   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
Local nPosQtdLib  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDLIB"})
Local nPosTes     := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
Local nPosLocal   := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})
Local nX          := 0

Local cTabela     := M->C5_TABELA

if EMPTY(cTabela)
	MsgInfo("Tabela de Preço não informada no Pedido de Venda!","Tabela inválida!")
	Return
endif

aAdd(aPWiz,{ 1,"Selecione a grade: "   ,Space(14) ,"","","Z01P","", ,.T.})
aAdd(aPWiz,{ 1,"Quantidade de grades: ",Space(6) ,"","","","", ,.T.})

aAdd(aRetWiz,Space(16))
aAdd(aRetWiz,Space(6))

lCont := ParamBox(aPWiz,"Selecione a Grade",@aRetWiz,,,,,,) 

If !lCont
	Return
EndIf

cCodGrd   := Alltrim(aRetWiz[1])
cQtd      := Alltrim(aRetWiz[2])
nQtd      := Val(cQtd)

If nQtd <= 0
	MsgInfo("O campo quantidade deve ser maior que zero!","Quantidade inválida!")
	Return
EndIf

cQuery := "SELECT R_E_C_N_O_, * FROM "
cQuery += RetSqlName("Z02") + " Z02 "
cQuery += " WHERE Z02_CODGRD = '" + cCodGrd + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

aCopy  := {}

nAcols := Len(aCols)

If Empty(aCols[1][2]) // cProduto
	aCopy := aCols
	aCols := {}
EndIf

Do While (cAliAux)->(!Eof())
	
	nLinha := Len(aCols) + 1
	
	Aadd(aCols,Array(Len(aHeader)+1))

	If !Empty(aCopy)
		For nx := 1 To Len(aHeader)
			aCols[nLinha][nX] := aCopy[1][nx]
		Next
	EndIf
	
	If Len(aCols)>1
		For nx := 1 To Len(aHeader)
			aCols[nLinha][nX] := aCols[1][nx]
		Next
	EndIf
	
	aCols[nLinha][nPosItem]    := STRZERO(nLinha, 2, 0)
	aCols[nLinha][nPosProd]    := (cAliAux)->Z02_COD
	aCols[nLinha][nPosUni]     := "UN"//BusDes410((cAliAux)->Z02_COD)
	aCols[nLinha][nPosQtdVen]  := nQtd * Val((cAliAux)->Z02_QTD)
	aCols[nLinha][nPosPrcVen]  := BusPre410(cTabela,(cAliAux)->Z02_COD)
	aCols[nLinha][nPosValor]   := ValItem410(cTabela,(cAliAux)->Z02_COD, (cAliAux)->Z02_QTD, cQtd)
	aCols[nLinha][nPosQtdLib]  := nQtd * Val((cAliAux)->Z02_QTD)
	aCols[nLinha][nPosTes]     := cTes
	aCols[nLinha][nPosLocal]   := "01"
	aCols[nLinha][nPosDescri]  := BusDes410((cAliAux)->Z02_COD)
	
	(cAliAux)->(DbSkip())
	
	A410LinOk()

EndDo

// U_xCompSc6()

RestArea( aArea )

Return

//-----------------------------------------------------------------------------------------------------------------------
Static Function BusDes410( cCod )

Local aArea     := GetArea() 
Local cDescri   := ""

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
cDescri := Alltrim(SB1->B1_DESC)

RestArea( aArea )

Return cDescri

//-----------------------------------------------------------------------------------------------------------------------
Static Function BusPre410( cTabela, cCod )

Local aArea       := GetArea() 
Local nPreco      := ""
Local nQuantidade := 0

DbSelectArea("DA1")
DbSetOrder(1) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
DbSeek(xFilial("DA1") + cTabela + cCod)
nPreco := DA1->DA1_PRCVEN
RestArea( aArea )

Return nPreco

//-----------------------------------------------------------------------------------------------------------------------
Static Function ValItem410( cTabela, cCod, nQuanti, cQtd )

Local aArea      := GetArea() 
Local nValor     := 0
Local nQtdIt     := 0
Local nVlr       := 0

DbSelectArea("DA1")
DbSetOrder(1) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
DbSeek(xFilial("DA1") + cTabela + cCod)

nQuanti := Val(nQuanti)
nValor := DA1->DA1_PRCVEN * nQuanti
nQtdIt := Val(cQtd)
nVlr   := nQtdIt * nValor

RestArea( aArea )

Return nVlr

//-----------------------------------------------------------------------------------------------------------------------
Static Function SeaUni410( cCod, cQtd )

Local aArea      := GetArea() 
Local cUnidade   := ""
Local nUnidade   := 0

cUnidade := ""
DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cCod)
	cUnidade := Alltrim(SB1->B1_UM)
EndIf

RestArea( aArea )

Return cUnidade
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ ACY0001    ³ Autor ³ Kurts               ³ Data ³ 12/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄda1ÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conferencia de Caixas apos Separacao via PickList          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ AVACY                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACY0001()

Local nOpc
Local _lFim		:= .F.

Private aTelaPri	:= VTSave() 
Private aItens      := {}

VtClearBuffer()
While .T.

	VTCLear()
	@ 0,0 VTSay "Selecione:"
	nOpc := VTaChoice(2,0,4,VTMaxCol(),{"Conferir PEDIDO"})
	
	VtClearBuffer()
	If nOpc == 1
		_lFim := U_ACDSRF0(_lFim)  // COnferir Pedido
		VTRestore(,,,,aTelaPri)
		Exit
	ElseIf nOpc == 2
		U_ACDSRF2()  // Consulta Produto
		VTRestore(,,,,aTelaPri)
	Else
		Exit
	EndIf

EndDo

Return


// Parte 1 - Informar Pedido, Obter as Caixas a serem conferidas e coloca-las em um array para confrontacao com os Bips
////////////////////////////////////////////////////
User Function ACDSRF0(_lFim)

Local bkey06

Local aTela 	:= VTSave()
Local nL    	:= VTRow()
Local nC    	:= VTCol()
Local _lContinua:= .T.

Private cPedido		:= Space(TamSx3("L2_NUM")[1])
Private cTpConf		:= "N"

bkey06 := VTSetKey(06,{|| BuscaCxs()},"Consulta Caixas") //Ctrl+F - Procurar  

VtClearBuffer()
While .T.
	
	VTClear()
	@ 0,0 VTSAY "CONFERENCIA PEDIDO"
	
	@ 2,0 VTSAY "Qual Pedido: " 
	@ 3,0 VTGet cPedido Pict '@!' Valid ConfPed(cPedido) .And. !Empty(cPedido)
	@ 4,0 VTSAY "Informa Quantidade: "
	@ 5,0 VTGet cTpConf Pict '@!' Valid !Empty(cTpConf)
	
	@ 7,0 VTSAY "Ctr-F: Cons. Pedidos"
	VTREAD
	
	If VTLASTKEY()==27
		If VTYesNo("Sair da Conferencia ?","ATENCAO",.T.)

			// AQUI COLOCARIA CODIGO PARA VALIDAR SE O PEDIDO FOI COMPLETAMENTE CONFERIDO
			// AVISANDO O USUARIO, QUE SE ELE SAIR, DEVERA RETOMAR A CONFERENCIA
			// SE FOI COMPLETAMENTE CONFERIDO LIBERAR O PEDIDO PARA SEGUIR PARA O FATURAMENTO

			Exit
		EndIf
	EndIf
	
	_lContinua := .T.
	
	If Empty(cPedido)
		VTBEEP(2)
		VTALERT("Favor informar o numero do PEDIDO a conferir !","AVISO",.T.,Nil)
		_lContinua := .F.
	EndIf
	 
	If !Empty(cPedido) .and. _lContinua
		
		vtsetkey(06,bkey06) // Desligar
	
		if SUBSTR(cPedido,1,1) == "F"

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6") + cPedido)) 
	
					_lFim := U_ACDSRF1(_lFim, cPedido)
	
					If _lFim
						Exit
					EndIf
			Else
				VTBEEP(2)
				VTALERT("Pedido NAO existe, verifique !","AVISO",.T.,Nil)
			EndIf

		else

			SL2->(DbSetOrder(1))
			If SL2->(DbSeek(xFilial("SL2") + cPedido)) 
	
					_lFim := U_ACDSRF1(_lFim, cPedido)
	
					If _lFim
						Exit
					EndIf
			Else
				VTBEEP(2)
				VTALERT("Pedido NAO existe, verifique !","AVISO",.T.,Nil)
			EndIf

		endif
	
		bKey06 := VTSetKey(06,{|| BuscaCxs()},"Consulta Caixas") // Religa  
	
	EndIf 
	
	cPedido		:= Space(TamSx3("L2_NUM")[1])
	cTpConf		:= "N"

EndDo

If _lFim
	VTClear()
Else
	VTRestore(,,,,aTela)
	@ nL,nC VtSay ""

	vtsetkey(06,bkey06)
EndIf

Return .T.


////////////////////////////////////////////////////
User Function ACDSRF1(_lFim, cPedido)

Local bkey09
Local aTela    := VTSave()
Local nL       := VTRow()
Local nC       := VTCol()
Local _cFr1	   := "Sair Conferencia ?"
Local cQuery   := ""
Local cConGrd  := GetNextAlias()

Private cEtiq     	:= Space(14) //Space(TamSx3("XX_LOTEXX")[1])
Private nQtdCxs		:= 0
Private _aSize      := {20, 10, 10}
Private _aCab       := {"Cod.Barra","Qtd.Ped","Qtd.Conf"}
Private _aConteudo	:= {} //{{"78901234567890",10,0},{"78901122334455",15,0},{"78908877665544",12,0},{"7890333333333",5,0}}

if SUBSTR(cPedido,1,1) == "F"
	cQuery := " SELECT C6_XGRADE XGRADE,"
	cQuery += "        C6_XQTD XQTD,"
	cQuery += "        C6_XQTDC XQTDC "
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "' 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY C6_XGRADE, C6_XQTD, C6_XQTDC" 
else
	cQuery := " SELECT L2_XGRADE XGRADE,"
	cQuery += "        L2_XQTD XQTD,"
	cQuery += "        L2_XQTDC XQTDC "
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "' 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY L2_XGRADE, L2_XQTD, L2_XQTDC" 
endif

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
(cConGrd)->(dbGoTop())
Do While (cConGrd)->(!Eof())
	AADD(_aConteudo,{(cConGrd)->XGRADE ,Val((cConGrd)->XQTD) ,Val((cConGrd)->XQTDC)})
	(cConGrd)->(DbSkip())
EndDo

bkey06 := VTSetKey(06,{|| _lFim := FimPed(@_lFim)},"Encerra Pedido") // Ctrl+F   
bkey01 := VTSetKey(01,{|| Ajuda(bkey01)},"Ajuda") // Ctrl+A
bKey09 := VTSetKey(09,{|| Informa(bKey09)},"Informações") // Ctrl-I

VtClearBuffer()
While .T.
	
	cEtiq     	:= Space(14)
	nQtdCxs		:= 0

	VTClear()
	@ 0,0 VTSAY "CONFERENCIA"
	@ 2,0 VTSAY "Etiqueta:" 
	If cTpConf == "N"
		@ 3,0 VTGet cEtiq Pict '@!' Valid !Empty(cEtiq) .and. VldCaixa(cEtiq, 1,cPedido)
	Else
		@ 3,0 VTGet cEtiq Pict '@!' Valid !Empty(cEtiq)
		@ 4,0 VTSAY "Quantidade:" 
		@ 5,0 VTGet nQtdCxs Pict '@E 999' Valid !Empty(nQtdCxs) .and. VldCaixa(cEtiq, nQtdCxs,cPedido)
	EndIf
	
	@ 7,0 VTSAY "ESC:Sair/CTR-I:Info"
	VTREAD

	If _lFim
		Exit
	EndIf

	If VTLASTKEY()==27
		aTela 	:= VTSave()
		If VTYesNo(_cFr1,"ATENCAO",.T.)
			//Limpando Itens 
			aItens := {}
			Exit
		EndIf
	EndIf
	
End

If _lFim
	VTClear()
	vtsetkey(09,bkey06)
	vtsetkey(09,bkey09)
	vtsetkey(01,bkey01)
Else
	VTRestore(,,,,aTela)
	@ nL,nC VtSay ""

	vtsetkey(09,bkey06)
	vtsetkey(09,bkey09)
	vtsetkey(01,bkey01)
EndIf

(cConGrd)->(dbCloseArea())

Return(_lFim)



////////////////////////////////////////////////////
User Function ACDSRF2()

U_ACDSRF1(.F.)

Return .f.

////////////////////////////////////////////////////
Static Function Ajuda(bkey01)

Local aTela 	:= VTSave()
Local cGet2		:= Space(1)

vtsetkey(01,bkey01) // Desligar

While .T.
	VTClear()
	@ 0,0 VTSAY "Ajuda Digitação"
	@ 2,0 VTSAY "Use CTR+I Conferencia

	@ 4,0 VTGet cGet2 Pict '@!'
	VTREAD
	
	If VTLASTKEY()==27
		Exit
	EndIf
EndDo

VTRestore(,,,,aTela)

bkey01 := VTSetKey(01,{|| Ajuda(bkey01)},"Ajuda") //Ctrl+A

Return .T.



// Valida se Etiqueta pertence ao pedido e a quantidade
////////////////////////////////////////////////////
Static Function VldCaixa(cChave,nQuant, cPedido)

Local nPos := 0
Local aTela := VTSave()

If Empty(cChave)
	Return
EndIf

// Verificando se o Produto ja esta no array
If Len(_aConteudo) > 0
	nPos := Ascan(_aConteudo,{|e| Alltrim(e[1]) == Alltrim(cChave)}) 
	If  nPos == 0
		VTBEEP(2)
		VTALERT("Etiqueta nao existe neste pedido !","VERIFIQUE",.T.,Nil)
		VTKeyBoard(chr(20))
	Else
		If cTpConf == "S"
			If _aConteudo[nPos,3] <> 0
				VTBEEP(2)
				VTALERT("Etiqueta ja conferida neste pedido !","VERIFIQUE",.T.,Nil)
				VTKeyBoard(chr(20))				
			Else
				If nQuant <> _aConteudo[nPos,2]
					VTBEEP(2)
					VTALERT("Esta nao e a quantidade correta desta etiqueta !","VERIFIQUE",.T.,Nil)
					VTKeyBoard(chr(20))
				Else
					VTBEEP(2)
					VTALERT("Etiqueta conferida com sucesso !","SUCESSO",.T.,Nil)
					VTKeyBoard(chr(20))	
					_aConteudo[nPos,3] := nQuant	
					GrvLote(_aConteudo,cPedido,cChave,nQuant)
				EndIf
			EndIf	
		Else
			_aConteudo[nPos,3] := _aConteudo[nPos,3] + 1
			GrvQtd(nPos, _aConteudo, _aConteudo[nPos,1],cPedido)
		EndIf
	EndIf
EndIf

VTRestore(,,,,aTela)

Return


// FUNCAO QUE MOSTRA AS ETIQUETAS A CONFERIR E JA CONFERIDAS
///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Informa(bkey09)

Local aTela 	:= VTSave()
Local nItem 	:= 1

vtsetkey(09,bkey09) // Desliga

IF Len(_aConteudo) > 0

	VtClear()
	
	@ 00,00 VTSay "Etiquetas Conferidas"
	nItem := VTaBrowse(01,00,VTMaxRow(),VTMaxCol(),_aCab,_aConteudo,_aSize,,nItem)
	
EndIf

VTRestore(,,,,aTela)

bKey09 := VTSetKey(09,{|| Informa(bKey09)},"Informações") // Religa

Return .T.



// Consulta EXEMPLO caso precise utilizar alguma no desenvolvimento, caso contratio pode apagar
///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function CliSql(cBusca)

Local aTela 	:= VTSave()
Local nItem 	:= 1
Local cQuery	:= ""
Local lAchou 	:= .F.
Local aItens	:= {}
Local aCab		:= {"Codigo","Lj","Nome","NomeRdz"}
Local aSize		:= {06, 02, 20, 20}
Local cAliasNew	:= GetNextAlias()


// Buscando Cliente com a parte informada e colocando em uma array
cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ  FROM "+RetSqlName('SA1')+" SA1X"
cQuery += " WHERE SA1X.A1_FILIAL = '"+xFilial("SA1")+"'"
cQuery +=   " AND SA1X.A1_NOME LIKE '%"+Alltrim(cBusca)+"%'"
cQuery +=   " AND SA1X.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)

If (cAliasNew)->(!Eof())
	lAchou := .T.
	While (cAliasNew)->(!Eof())
		AAdd(aItens,{(cAliasNew)->A1_COD, (cAliasNew)->A1_LOJA, Substr((cAliasNew)->A1_NOME,1,20), Substr((cAliasNew)->A1_NREDUZ,1,20) })
		(cAliasNew)->(DbSkip())
	EndDo

	IF Len(aItens) > 0
		@ 00,00 VTSay "Clientes Encontrados"
		nItem := VTaBrowse(01,00,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,,nItem)
	Else
		VTBEEP(2)
		VTALERT("Não encontrado !","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))
	EndIf
Else
		VTBEEP(2)
		VTALERT("Não encontrado !","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))
EndIf

(cAliasNew)->(dbCloseArea())	
VTRestore(,,,,aTela)

Return .T.

///////////////////////////////////////////////////////////////////////////
Static Function GrvQtd(nPos, _aConteudo, cGrade, cPedido)

Local cConGrd  := GetNextAlias()
Local cQuery   := ""
Local nQuant   := 0
Local lCont    := .T.
Local _lFim    := .F.


if SUBSTR(cPedido,1,1) == "F"
	cQuery += " SELECT C6_XGRADE XGRADE,"
	cQuery += "        C6_XQTD XQTD,"
	cQuery += "        C6_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND C6_XGRADE = '" + cGrade + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY C6_XGRADE, C6_XQTD, C6_XQTDC, R_E_C_N_O_" 
else
	cQuery += " SELECT L2_XGRADE XGRADE,"
	cQuery += "        L2_XQTD XQTD,"
	cQuery += "        L2_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND L2_XGRADE = '" + cGrade + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY L2_XGRADE, L2_XQTD, L2_XQTDC, R_E_C_N_O_" 
endif


cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
(cConGrd)->(dbGoTop())
Do While (cConGrd)->(!Eof()) 

	dbSelectArea("SL2")
	SL2->(dbGoto((cConGrd)->R_E_C_N_O_))
	
	nQuant := Val((cConGrd)->XQTDC)
	nQuant := nQuant + 1
	
	If Val((cConGrd)->L2_XQTDC) < Val((cConGrd)->XQTD) 

		if SUBSTR(cPedido,1,1) == "F"

			RecLock("SC6",.F.)
			SC6->C6_XQTDC := Alltrim(Str(nQuant))
			If !lCont
				SC6->C6_XCONF := "S"
			EndIf
			MsUnLock()
			
			If Val(SC6->C6_XQTDC) == Val((cConGrd)->XQTD)
				If lCont
					RecLock("SC6",.F.)
					SC6->C6_XCONF := "S"
					MsUnLock()
	
					VTBEEP(2)
					VTALERT("Grade conferida, pedido liberado!","Conferido",.T.,Nil)
					VTKeyBoard(chr(20))	
					lCont := .F.
					GrvSl1(cPedido)
				EndIf
			EndIf

		else

			RecLock("SL2",.F.)
			SL2->L2_XQTDC := Alltrim(Str(nQuant))
			If !lCont
				SL2->L2_XCONF := "S"
			EndIf
			MsUnLock()
			
			If Val(SL2->L2_XQTDC) == Val((cConGrd)->XQTD)
				If lCont
					RecLock("SL2",.F.)
					SL2->L2_XCONF := "S"
					MsUnLock()
	
					VTBEEP(2)
					VTALERT("Grade conferida, pedido liberado!","Conferido",.T.,Nil)
					VTKeyBoard(chr(20))	
					lCont := .F.
					GrvSl1(cPedido)
				EndIf
			EndIf

		endif
		
		
	Else

		VTBEEP(2)
		VTALERT("Grade ja foi conferida, pedido liberado!","Conferido",.T.,Nil)
		VTKeyBoard(chr(20))	
		_lFim := U_ACDSRF0(_lFim)
		
	EndIf
				 
	(cConGrd)->(DbSkip())	
	
EndDo

If !lCont
	_lFim := U_ACDSRF0(_lFim)
EndIf

(cConGrd)->(dbCloseArea())	

Return

//////////////////////////////////////////////
Static Function GrvSl1(cPedido)

Local aArea := GetArea()

if SUBSTR(cPedido,1,1) == "F"

	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(dbSeek( xFilial("SC5") + cPedido))
		RecLock("SC5",.F.)
			SC5->C5_XCONF := "S"
		MsUnLock()
	EndIf

else

	DbSelectArea("SL1")
	DbSetOrder(1)
	If SL1->(dbSeek( xFilial("SL1") + cPedido))
		RecLock("SL1",.F.)
			SL1->L1_XCONF := "S"
		MsUnLock()
	EndIf

endif


RestArea(aArea)

Return

////////////////////////////////////////////////////
Static Function ConfPed(cPedido)

Local aArea := GetArea()
Local lRet  := .T.


if SUBSTR(cPedido,1,1) == "F"
	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(dbSeek( xFilial("SC5") + cPedido))
		If !Empty(SC5->C5_XCONF)
			VTBEEP(2)
			VTALERT("Pedido ja conferido e liberado!","Conferido",.T.,Nil)
			VTKeyBoard(chr(20))	
			_lFim := U_ACDSRF0(_lFim)
		Else
			lRet := .T.
		EndIf
	Else
		VTBEEP(2)
		VTALERT("Pedido nao localizado","Nao Localizado",.T.,Nil)
		VTKeyBoard(chr(20))	
		_lFim := U_ACDSRF0(_lFim)
	EndIf
else
	DbSelectArea("SL1")
	DbSetOrder(1)
	If SL1->(dbSeek( xFilial("SL1") + cPedido))
		If !Empty(SL1->L1_XCONF)
			VTBEEP(2)
			VTALERT("Pedido ja conferido e liberado!","Conferido",.T.,Nil)
			VTKeyBoard(chr(20))	
			_lFim := U_ACDSRF0(_lFim)
		Else
			lRet := .T.
		EndIf
	Else
		VTBEEP(2)
		VTALERT("Pedido nao localizado","Nao Localizado",.T.,Nil)
		VTKeyBoard(chr(20))	
		_lFim := U_ACDSRF0(_lFim)
	EndIf
endif

		
RestArea(aArea)

Return lRet

////////////////////////////////////////////////////
Static Function GrvLote(_aConteudo,cPedido,cChave,nQuant)

Local cConGrd  := GetNextAlias()
Local cQuery   := ""
Local nQtd     := nQuant
Local aArea    := GetArea()
Local lGrvSl1  := .F.

if SUBSTR(cPedido,1,1) == "F"

	cQuery += " SELECT C6_XGRADE,"
	cQuery += "        C6_XQTD,"
	cQuery += "        C6_XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND C6_XGRADE = '" + cChave + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY C6_XGRADE, C6_XQTD, C6_XQTDC, R_E_C_N_O_" 
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
	(cConGrd)->(dbGoTop())
	Do While (cConGrd)->(!Eof()) 
		dbSelectArea("SC6")
		SC6->(dbGoto((cConGrd)->R_E_C_N_O_))
		RecLock("SC6",.F.)
		SC6->C6_XQTDC := Alltrim(Str(nQtd))
		SC6->C6_XCONF := "S"
		MsUnLock()
		(cConGrd)->(DbSkip())	
	EndDo
	(cConGrd)->(dbCloseArea())	

else

	cQuery += " SELECT L2_XGRADE,"
	cQuery += "        L2_XQTD,"
	cQuery += "        L2_XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND L2_XGRADE = '" + cChave + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY L2_XGRADE, L2_XQTD, L2_XQTDC, R_E_C_N_O_" 
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
	(cConGrd)->(dbGoTop())
	Do While (cConGrd)->(!Eof()) 
		dbSelectArea("SL2")
		SL2->(dbGoto((cConGrd)->R_E_C_N_O_))
		RecLock("SL2",.F.)
		SL2->L2_XQTDC := Alltrim(Str(nQtd))
		SL2->L2_XCONF := "S"
		MsUnLock()
		(cConGrd)->(DbSkip())	
	EndDo
	(cConGrd)->(dbCloseArea())	

endif

lGrvSl1 := ConfLote(_aConteudo,cPedido,cChave,nQtd)

If lGrvSl1
	GrvSl1(cPedido)
EndIf

RestArea(aArea)

Return

////////////////////////////////////////////////////
Static Function ConfLote(_aConteudo,cPedido,cChave,nQuant)

Local cConGrd  := GetNextAlias()
Local cQuery   := ""
Local nQtd     := nQuant
Local aArea    := GetArea()
Local nQtdTot  := 0
Local nQtdConf := 0
Local lRet     := .F.

if SUBSTR(cPedido,1,1) == "F"
	cQuery += " SELECT C6_XGRADE,"
	cQuery += "        C6_XQTD,"
	cQuery += "        C6_XQTDC"
	cQuery += "  FROM " + RetSqlName('SC6') 
	cQuery += " WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "   AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY C6_XGRADE, C6_XQTD, C6_XQTDC"
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
	(cConGrd)->(dbGoTop())
	Do While (cConGrd)->(!Eof()) 
		nQtdTot  += Val((cConGrd)->C6_XQTD)
		nQtdConf += Val((cConGrd)->C6_XQTDC)
		(cConGrd)->(DbSkip())	
	EndDo
	(cConGrd)->(dbCloseArea())	
else
	cQuery += " SELECT L2_XGRADE,"
	cQuery += "        L2_XQTD,"
	cQuery += "        L2_XQTDC"
	cQuery += "  FROM " + RetSqlName('SL2') 
	cQuery += " WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "   AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY L2_XGRADE, L2_XQTD, L2_XQTDC"
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
	(cConGrd)->(dbGoTop())
	Do While (cConGrd)->(!Eof()) 
		nQtdTot  += Val((cConGrd)->L2_XQTD)
		nQtdConf += Val((cConGrd)->L2_XQTDC)
		(cConGrd)->(DbSkip())	
	EndDo
	(cConGrd)->(dbCloseArea())	
endif

If nQtdTot == nQtdConf
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet
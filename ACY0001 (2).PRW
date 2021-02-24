#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ ACY0001    ³ Autor ³ Kurts               ³ Data ³ 12/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄda1ÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
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
	nOpc := VTaChoice(2,0,4,VTMaxCol(),{"1-Conferir"})
	
	VtClearBuffer()
	If nOpc == 1
		_lFim := U_DigPed(_lFim)  // Conferir Pedido
		VTRestore(,,,,aTelaPri)
		Exit
	Else
		Exit
	EndIf

EndDo

Return


///////////////////////////////////////////////////////////////////////////////////////////////////
User Function DigPed(_lFim)

Local aTela 	 := VTSave()
Local nL    	 := VTRow()
Local nC    	 := VTCol()
Local _lContinua := .T.

Private cPedido		:= Space(TamSx3("L2_NUM")[1])
Private cTpConf		:= "N"

VtClearBuffer()
While .T.
	
	VTClear()

	@ 2,0 VTSAY "Pedido: " 
	@ 3,0 VTGet cPedido Pict '@!' Valid Conf_Ped(cPedido) .And. !Empty(cPedido)
	@ 4,0 VTSAY "Por quantidade: "
	@ 5,0 VTGet cTpConf Pict '@!' Valid !Empty(cTpConf) .and. cTpConf $ ("S/s/N/n")
	
	VTREAD
	
	If VTLASTKEY()==27
		If VTYesNo("Sair da rotina de conferencia?","ATENCAO",.T.)
			Exit
		EndIf
	EndIf
	
	_lContinua := .T.
	
	If Empty(cPedido)
		VTBEEP(2)
		VTALERT("Pedido nao informado!","AVISO",.T.,Nil)
		_lContinua := .F.
	EndIf
	 
	If !Empty(cPedido) .and. _lContinua
		
		if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6") + cPedido)) 
	
					_lFim := U_Dig_Etiq(_lFim, cPedido)
	
					If _lFim
						Exit
					EndIf
			Else
			
				VTBEEP(2)
				VTALERT("Pedido nao existe!","AVISO",.T.,Nil)

			EndIf

			cPedido	:= Space(TamSx3("C6_NUM")[1])
			cTpConf	:= "N"

		else

			SL2->(DbSetOrder(1))
			If SL2->(DbSeek(xFilial("SL2") + cPedido)) 
	
					_lFim := U_Dig_Etiq(_lFim, cPedido)
	
					If _lFim
						Exit
					EndIf
			Else
				VTBEEP(2)
				VTALERT("Pedido nao existe!","AVISO",.T.,Nil)

			EndIf

			cPedido	:= Space(TamSx3("L2_NUM")[1])
			cTpConf	:= "N"

		endif
	
	EndIf 

EndDo

If _lFim
	VTClear()
Else
	VTRestore(,,,,aTela)
	@ nL,nC VtSay ""
EndIf

Return .T.

///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Conf_Ped(cPedido)

Local aArea := GetArea()
Local lRet  := .T.

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(dbSeek( xFilial("SC5") + cPedido))
		If SC5->C5_XCONF=="S"
			VTBEEP(2)
			VTALERT("ja foi realizada a conferencia do Pedido!","AVISO",.T.,Nil)
			VTKeyBoard(chr(20))	
			_lFim := U_DigPed(_lFim)
		Else
			lRet := .T.
		EndIf
	Else
		VTBEEP(2)
		VTALERT("Pedido nao localizado!","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))	
		_lFim := U_DigPed(_lFim)
	EndIf
else
	DbSelectArea("SL1")
	DbSetOrder(1)
	If SL1->(dbSeek( xFilial("SL1") + cPedido))
		If SL1->L1_XCONF=="S"
			VTBEEP(2)
			VTALERT("ja foi realizada a conferencia do Pedido!","AVISO",.T.,Nil)
			VTKeyBoard(chr(20))	
			_lFim := U_DigPed(_lFim)
		Else
			lRet := .T.
		EndIf
	Else
		VTBEEP(2)
		VTALERT("Pedido nao localizado!","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))	
		_lFim := U_DigPed(_lFim)
	EndIf
endif

		
RestArea(aArea)

Return lRet


///////////////////////////////////////////////////////////////////////////////////////////////////
User Function Dig_Etiq(_lFim, cPedido)

Local bkey09
Local aTela    := VTSave()
Local nL       := VTRow()
Local nC       := VTCol()
Local cQuery   := ""
Local cConGrd1 := GetNextAlias()
Local cConGrd2 := GetNextAlias()

Private cEtiq     	:= Space(14) 
Private nCxs		:= 0
Private _aSize      := {14, 4, 4}
Private _aCab       := {"Etiqueta","Quantidade","Conferido"}
Private _aConteudo	:= {} 

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")

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
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd2,.T.,.T.)
(cConGrd2)->(dbGoTop())
Do While (cConGrd2)->(!Eof())
	AADD(_aConteudo,{(cConGrd2)->XGRADE ,Val((cConGrd2)->XQTD) ,Val((cConGrd2)->XQTDC)})
	(cConGrd2)->(DbSkip())
EndDo

bkey01 := VTSetKey(01,{|| Ajuda(bkey01)},"Ajuda") // Ctrl+A
bKey09 := VTSetKey(09,{|| Informa(bKey09)},"Conferidas") // Ctrl-I

VtClearBuffer()
While .T.
	
	cEtiq := Space(14)
	nCxs  := 0

	VTClear()
	@ 0,0 VTSAY "# CONFERENCIA #"
	@ 2,0 VTSAY "Etiqueta:" 
	If cTpConf == "N"
		@ 3,0 VTGet cEtiq Pict '@!' Valid !Empty(cEtiq) .and. VldCaixa(cEtiq, 1, cPedido)
	Else
		@ 3,0 VTGet cEtiq Pict '@!' Valid !Empty(cEtiq)
		@ 4,0 VTSAY "Quantidade:" 
		@ 5,0 VTGet nCxs Pict '@E 999' Valid !Empty(nCxs) .and. VldCaixa(cEtiq, nCxs, cPedido)
	EndIf

	@ 6,0 VTSAY "ESC - Sair"
	@ 7,0 VTSAY "CTR-I - Conferidas"
	VTREAD

	If _lFim
		Exit
	EndIf

	If VTLASTKEY()==27
		aTela 	:= VTSave()

		if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
			cQuery := " SELECT C6_XGRADE XGRADE,"
			cQuery += "        C6_XQTD XQTD,"
			cQuery += "        C6_XQTDC XQTDC,"
			cQuery += "        R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName('SC6') 
			cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
			cQuery += "    AND D_E_L_E_T_ = ' '" 
		else
			cQuery := " SELECT L2_XGRADE XGRADE,"
			cQuery += "        L2_XQTD XQTD,"
			cQuery += "        L2_XQTDC XQTDC,"
			cQuery += "        R_E_C_N_O_"
			cQuery += "   FROM " + RetSqlName('SL2') 
			cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
			cQuery += "    AND D_E_L_E_T_ = ' '" 
		endif
		lParcial := .F.
		cQuery := ChangeQuery(cQuery) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd1,.T.,.T.)
		(cConGrd1)->(dbGoTop())
		Do While (cConGrd1)->(!Eof()) 
			if Val((cConGrd1)->XQTDC) > 0  
				lParcial:= .T.
			endif
			(cConGrd1)->(DbSkip())	
		EndDo
		(cConGrd1)->(dbCloseArea())	
		
		if lParcial 

			If VTYesNo("Conferencia parcial! Deseja sair da conferencia?","ATENCAO",.T.)
				aItens := {}
				Exit
			EndIf

		else
		
			If VTYesNo("Deseja sair da conferencia?","ATENCAO",.T.)
				aItens := {}
				Exit
			EndIf
		
		endif

	EndIf
	
End

If _lFim
	VTClear()

	vtsetkey(09,bkey09)
	vtsetkey(01,bkey01)
Else
	VTRestore(,,,,aTela)
	@ nL,nC VtSay ""

	vtsetkey(09,bkey09)
	vtsetkey(01,bkey01)
EndIf

(cConGrd2)->(dbCloseArea())

Return(_lFim)


///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Ajuda(bkey01)

Local aTela 	:= VTSave()
Local cGet2		:= Space(1)

vtsetkey(01,bkey01) // Desligar

While .T.
	VTClear()

	@ 0,0 VTSAY "Ajuda Digitação"
	@ 2,0 VTSAY "Use CTR+I Conferencia"

	@ 4,0 VTGet cGet2 Pict '@!'
	VTREAD
	
	If VTLASTKEY()==27
		Exit
	EndIf
EndDo

VTRestore(,,,,aTela)

bkey01 := VTSetKey(01,{|| Ajuda(bkey01)},"Ajuda") //Ctrl+A

Return .T.


///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function VldCaixa(cEtiq, nQuant, cPedido)

Local nPos := 0
Local aTela := VTSave()

If Empty(cEtiq)
	Return
EndIf

If Len(_aConteudo) > 0
	nPos := Ascan(_aConteudo,{|e| Alltrim(e[1]) == Alltrim(cEtiq)}) 
	If  nPos == 0
		VTBEEP(2)
		VTALERT("Etiqueta nao existe neste pedido!","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))
	Else
		If cTpConf == "S"
			If _aConteudo[nPos,3] <> 0
				VTBEEP(2)
				VTALERT("Etiqueta ja conferida neste pedido!","AVISO",.T.,Nil)
				VTKeyBoard(chr(20))				
			Else
				If nQuant <> _aConteudo[nPos,2]
					VTBEEP(2)
					VTALERT("Quantidade da etiqueta diferente do pedido!","AVISO",.T.,Nil)
					VTKeyBoard(chr(20))
				Else
					_aConteudo[nPos,3] := nQuant	

					Grv_Quant(_aConteudo, cPedido, cEtiq, nQuant)

					VTBEEP(2)
					VTALERT("Total da etiqueta conferida!","AVISO",.T.,Nil)
					VTKeyBoard(chr(20))	

				EndIf
			EndIf	
		Else
			Grv_Unid(_aConteudo, cPedido, cEtiq )
		EndIf
	EndIf
EndIf

VTRestore(,,,,aTela)

Return


///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Grv_Unid(_aConteudo, cPedido, cEtiq)

Local cConGrd3  := GetNextAlias()
Local cConGrd4  := GetNextAlias()

Local cQuery   := ""
Local nQuant   := 0
Local _lFim    := .F.
Local lGrade   := .T.

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
	cQuery := " SELECT C6_XGRADE XGRADE,"
	cQuery += "        C6_XQTD XQTD,"
	cQuery += "        C6_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND C6_XGRADE = '" + cEtiq + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
else
	cQuery := " SELECT L2_XGRADE XGRADE,"
	cQuery += "        L2_XQTD XQTD,"
	cQuery += "        L2_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND L2_XGRADE = '" + cEtiq + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
endif

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd3,.T.,.T.)
(cConGrd3)->(dbGoTop())

If Val((cConGrd3)->XQTD) <> Val((cConGrd3)->XQTDC) 

	Do While (cConGrd3)->(!Eof()) 
	
		if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
			dbSelectArea("SC6")
			SC6->(dbGoto((cConGrd3)->R_E_C_N_O_))
		else
			dbSelectArea("SL2")
			SL2->(dbGoto((cConGrd3)->R_E_C_N_O_))
		endif
		
		nQuant := Val((cConGrd3)->XQTDC)
		nQuant := nQuant + 1
		
		If Val((cConGrd3)->XQTD) <> Val((cConGrd3)->XQTDC) 
	
			if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
	
				RecLock("SC6",.F.)
				SC6->C6_XQTDC := Alltrim(Str(nQuant))
				MsUnLock()

				nPos := Ascan(_aConteudo,{|e| Alltrim(e[1]) == Alltrim(cEtiq)}) 
				_aConteudo[nPos,3] := nQuant
				
				If Val(SC6->C6_XQTDC) == Val(SC6->C6_XQTD)
					RecLock("SC6",.F.)
					SC6->C6_XCONF := "S"
					MsUnLock()
				else
					lGrade   := .F.
				endIf
	
			else
	
				RecLock("SL2",.F.)
				SL2->L2_XQTDC := Alltrim(Str(nQuant))
				MsUnLock()

				nPos := Ascan(_aConteudo,{|e| Alltrim(e[1]) == Alltrim(cEtiq)}) 
				_aConteudo[nPos,3] := nQuant
				
				If Val(SL2->L2_XQTDC) == Val(SL2->L2_XQTD)
					RecLock("SL2",.F.)
					SL2->L2_XCONF := "S"
					MsUnLock()
				else
					lGrade   := .F.
				EndIf
	
			endif
	
		endif
		
		(cConGrd3)->(DbSkip())	
		
	EndDo

	if lGrade
		VTBEEP(2)
		VTALERT("Total da etiqueta conferida!","AVISO",.T.,Nil)
		VTKeyBoard(chr(20))	
	endif
	
else
	VTBEEP(2)
	VTALERT("Etiqueta Excedida!","AVISO",.T.,Nil)
	VTKeyBoard(chr(20))	
EndIf

(cConGrd3)->(dbCloseArea())	

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
	cQuery := " SELECT C6_XGRADE XGRADE,"
	cQuery += "        C6_XQTD XQTD,"
	cQuery += "        C6_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND D_E_L_E_T_ = ' '" 
else
	cQuery := " SELECT L2_XGRADE XGRADE,"
	cQuery += "        L2_XQTD XQTD,"
	cQuery += "        L2_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND D_E_L_E_T_ = ' '" 
endif
lFinaliza := .T.
cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd4,.T.,.T.)
(cConGrd4)->(dbGoTop())
Do While (cConGrd4)->(!Eof()) 
	If Val((cConGrd4)->XQTD) <> Val((cConGrd4)->XQTDC) 
		lFinaliza := .F.
	endif
	(cConGrd4)->(DbSkip())	
EndDo
(cConGrd4)->(dbCloseArea())	

if lFinaliza 

	aArea := GetArea()
	
	if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
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

	VTBEEP(2)
	VTALERT("Finalizada conferencia do pedido!","AVISO",.T.,Nil)
	VTKeyBoard(chr(20))	
	
	RestArea(aArea)

	_lFim := U_DigPed(_lFim)

endif

Return

///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Grv_Quant(_aConteudo, cPedido, cEtiq, nQuant)

Local cConGrd5   := GetNextAlias()
Local cConGrd6   := GetNextAlias()

Local cQuery     := ""

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")

	cQuery := " SELECT C6_XGRADE,"
	cQuery += "        C6_XQTD,"
	cQuery += "        C6_XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND C6_XGRADE = '" + cEtiq + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY C6_XGRADE, C6_XQTD, C6_XQTDC, R_E_C_N_O_" 
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd5,.T.,.T.)
	(cConGrd5)->(dbGoTop())
	Do While (cConGrd5)->(!Eof()) 
		dbSelectArea("SC6")
		SC6->(dbGoto((cConGrd5)->R_E_C_N_O_))
		RecLock("SC6",.F.)
		SC6->C6_XQTDC := Alltrim(Str(nQuant))
		SC6->C6_XCONF := "S"
		MsUnLock()
		(cConGrd5)->(DbSkip())	
	EndDo
	(cConGrd5)->(dbCloseArea())	

else

	cQuery := " SELECT L2_XGRADE,"
	cQuery += "        L2_XQTD,"
	cQuery += "        L2_XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND L2_XGRADE = '" + cEtiq + " '" 
	cQuery += "    AND D_E_L_E_T_ = ' '" 
	cQuery += "  GROUP BY L2_XGRADE, L2_XQTD, L2_XQTDC, R_E_C_N_O_" 
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd5,.T.,.T.)
	(cConGrd5)->(dbGoTop())
	Do While (cConGrd5)->(!Eof()) 
		dbSelectArea("SL2")
		SL2->(dbGoto((cConGrd5)->R_E_C_N_O_))
		RecLock("SL2",.F.)
		SL2->L2_XQTDC := Alltrim(Str(nQuant))
		SL2->L2_XCONF := "S"
		MsUnLock()
		(cConGrd5)->(DbSkip())	
	EndDo

	(cConGrd5)->(dbCloseArea())	

endif

if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
	cQuery := " SELECT C6_XGRADE XGRADE,"
	cQuery += "        C6_XQTD XQTD,"
	cQuery += "        C6_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SC6') 
	cQuery += "  WHERE C6_NUM = '"+ cPedido + "'
	cQuery += "    AND D_E_L_E_T_ = ' '" 
else
	cQuery := " SELECT L2_XGRADE XGRADE,"
	cQuery += "        L2_XQTD XQTD,"
	cQuery += "        L2_XQTDC XQTDC,"
	cQuery += "        R_E_C_N_O_"
	cQuery += "   FROM " + RetSqlName('SL2') 
	cQuery += "  WHERE L2_NUM = '"+ cPedido + "'
	cQuery += "    AND D_E_L_E_T_ = ' '" 
endif
lFinaliza := .T.
cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd6,.T.,.T.)
(cConGrd6)->(dbGoTop())
Do While (cConGrd6)->(!Eof()) 
	If Val((cConGrd6)->XQTD) <> Val((cConGrd6)->XQTDC) 
		lFinaliza := .F.
	endif
	(cConGrd6)->(DbSkip())	
EndDo
(cConGrd6)->(dbCloseArea())	

if lFinaliza 

	aArea := GetArea()
	
	if !(SUBSTR(cPedido,1,1) $ "0/1/2/3/4/5/6/7/8/9/A/B/C/D/E")
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

	VTBEEP(2)
	VTALERT("Finalizada conferencia do pedido!","AVISO",.T.,Nil)
	VTKeyBoard(chr(20))	
	
	RestArea(aArea)

	_lFim := U_DigPed(_lFim)

endif

Return


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

bKey09 := VTSetKey(09,{|| Informa(bKey09)},"Conferidas") // Religa

Return .T.


#Include 'Protheus.ch'


//////////////////////////////////
User Function AvcConf(cTipo)

Local cPedido  
Local cTipo
Local lStatus 

if cTipo == "LOJA"
    cPedido  := SL1->L1_NUM
	lStatus := SL1->L1_SITUA <> "OK" .AND. Empty(SL1->L1_RESERVA) .AND. dDataBase <=SL1->L1_DTLIM

	If !lStatus
		MsgInfo( "Pedido já Concluido!", "Loja" )
	Else
		Janela(cTipo,cPedido)
	EndIf

else

   cPedido  := SC5->C5_NUM
   lStatus := !Empty(C5_NOTA) .OR. C5_LIBEROK=='E' .AND. Empty(C5_BLQ)

	If lStatus
		MsgInfo( "Pedido já Concluido!", "Faturamento" )
	Else
		Janela(cTipo,cPedido)
	EndIf

endif


Return 

Static Function Janela(cTipo,cPedido)

Local oDlg
Local oBtn1,oBtn2,oSay1
 
DEFINE DIALOG oDlg TITLE "Conferência Automática" FROM 0,0 TO 150,250 COLOR CLR_BLACK,CLR_WHITE PIXEL
@ 25,10 SAY oSay1 PROMPT "Escolha uma ação:" SIZE 120,24 OF oDlg PIXEL 
 
@ 50,10 BUTTON oBtn1 PROMPT 'Limpar Conferencia'  ACTION ( AvcLimp(cTipo, cPedido),oDlg:End() ) SIZE 50, 015 OF oDlg PIXEL
@ 50,65 BUTTON oBtn2 PROMPT 'Conferir Lote' ACTION ( AvcCfl(cTipo, cPedido), oDlg:End() ) SIZE 50, 015 OF oDlg PIXEL

ACTIVATE DIALOG oDlg CENTER

Return


//////////////////////////////////
Static Function AvcLimp(cTipo, cPedido)

Local cAliSql := GetNextAlias()
Local cSql    := ""
Local aArea   := GetArea() 

If MSGYESNO( "Limpar a conferência?", "Conferência" )

	if cTipo == "LOJA"
		cSql := "SELECT R_E_C_N_O_, * FROM "+RetSqlName("SL2") + " SL2 "
		cSql += " WHERE L2_NUM = '" + cPedido + "' " 
		cSql += "   AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
		(cAliSql)->(dbGotop())
		Do While !(cAliSql)->(Eof())
			SL2->(dbGoto((cAliSql)->R_E_C_N_O_))
			RecLock("SL2",.F.)
				SL2->L2_XQTDC := ""
				SL2->L2_XCONF := ""
			MsUnLock()
			(cAliSql)->(DbSkip())	
		EndDo
		(cAliSql)->(dbCloseArea())	

		DbSelectArea("SL1")
		DbSetOrder(1)
		If SL1->(dbSeek( xFilial("SL1") + cPedido))
			RecLock("SL1",.F.)
			SL1->L1_XCONF := ""
			MsUnLock()
		EndIf

	endif
	
	if cTipo == "FAT"
		cSql := "SELECT R_E_C_N_O_, * FROM "+RetSqlName("SC6") + " SC6 "
		cSql += " WHERE C6_NUM = '" + cPedido + "' " 
		cSql += "   AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
		(cAliSql)->(dbGotop())
		Do While !(cAliSql)->(Eof())
			SC6->(dbGoto((cAliSql)->R_E_C_N_O_))
			RecLock("SC6",.F.)
			SC6->C6_XQTDC := ""
			SC6->C6_XCONF := ""
			MsUnLock()
			(cAliSql)->(DbSkip())	
		EndDo
		(cAliSql)->(dbCloseArea())	

		DbSelectArea("SC5")
		DbSetOrder(1)
		If SC5->(dbSeek( xFilial("SC5") + cPedido))
			RecLock("SC5",.F.)
			SC5->C5_XCONF := ""
			MsUnLock()
		EndIf
	endif

	MsgInfo( "Processo Concluido!", "Aviso" )
	
EndIf

RestArea( aArea )

Return


//////////////////////////////////
Static Function AvcCfl(cTipo, cPedido)

Local cAliSql := GetNextAlias()
Local cSql    := ""
Local aArea   := GetArea() 

If MSGYESNO( "Conferir o pedido em sua totalidade?", "Conferência" )

	if cTipo == "LOJA"
		cSql := "SELECT R_E_C_N_O_, * FROM "+RetSqlName("SL2") + " SL2 "
		cSql += " WHERE L2_NUM = '" + cPedido + "' " 
		cSql += "   AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
		(cAliSql)->(dbGotop())
		Do While !(cAliSql)->(Eof())
			SL2->(dbGoto((cAliSql)->R_E_C_N_O_))
			RecLock("SL2",.F.)
			SL2->L2_XQTDC := SL2->L2_XQTD
			SL2->L2_XCONF := "S"
			MsUnLock()
			(cAliSql)->(DbSkip())	
		EndDo
		(cAliSql)->(dbCloseArea())	

		DbSelectArea("SL1") 
		DbSetOrder(1)
		If SL1->(dbSeek( xFilial("SL1") + cPedido))
			RecLock("SL1",.F.)
			SL1->L1_XCONF := "S"
			MsUnLock()
		EndIf

	endif

	if cTipo == "FAT"
		cSql := "SELECT R_E_C_N_O_, * FROM "+RetSqlName("SC6") + " SC6 "
		cSql += " WHERE C6_NUM = '" + cPedido + "' " 
		cSql += "   AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
		(cAliSql)->(dbGotop())
		Do While !(cAliSql)->(Eof())
			SC6->(dbGoto((cAliSql)->R_E_C_N_O_))
			RecLock("SC6",.F.)
			SC6->C6_XQTDC := SC6->C6_XQTD
			SC6->C6_XCONF := "S"
			MsUnLock()
			(cAliSql)->(DbSkip())	
		EndDo
		(cAliSql)->(dbCloseArea())	

		DbSelectArea("SC5")
		DbSetOrder(1)
		If SC5->(dbSeek( xFilial("SC5") + cPedido))
			RecLock("SC5",.F.)
			SC5->C5_XCONF := "S"
			MsUnLock()
		EndIf

	endif

	MsgInfo( "Processo Concluido!", "Aviso" )
	
EndIf

RestArea( aArea )

Return


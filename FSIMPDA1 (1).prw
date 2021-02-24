#Include "PROTHEUS.CH"
#include "TopConn.ch"
#include "TbiConn.CH"
#include "TbiCode.ch"
#include "rwmake.CH"
#INCLUDE "totvs.ch"
#INCLUDE "FILEIO.CH"

#DEFINE ENTER chr(13)+chr(10)

Static cArquivo := "Log_nao_incluso_"+SUBSTR(DTOC(ddatabase),1,2)+SUBSTR(DTOC(ddatabase),4,2)+SUBSTR(DTOC(ddatabase),9,2)+"_"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+".csv"

/////////////////////////////////////////////////
// Caixa de dialogo com usuario.
user function FSIMPDA1()

	Private lMaisAlt := .F.
	Private oDlg
	Private dVigencia := CTOD("31/12/2049")
														
	DEFINE MSDIALOG oDlg FROM 0,0 TO 250,250 PIXEL TITLE "Importar Tabela de Preço"
	@ 005,05 Say "Vigencia: "  of oDlg Pixel
	@ 015,05 MsGet dVigencia Picture "@!" When .f. of oDlg Pixel 

	@ 105,028+33 BUTTON "Processar"   SIZE 30,13 PIXEL OF oDlg ACTION FSIMP002(oDlg)
	@ 105,073+20 BUTTON "Sair"        SIZE 30,13 PIXEL OF oDlg ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
Return

/////////////////////////////////////////////////
// Na inclusão se a data está preenchida e processa o programa.
Static Function FSIMP002()

	If Empty(dVigencia)
		If MSGYESNO("A T E N Ç Ã O" + CRLF + CRLF + "O campo Data de vigencia está em branco deseja realmente continuar?", "DATA")
			Processa({|| FSIMP003()}, "Aguarde...", "Atualizando dados...")
			oDlg:end()
			Return
		EndIf
	Else
		Processa({|| FSIMP003()}, "Aguarde...", "Atualizando dados...")		
	EndIf

	If !lMaisAlt
		oDlg:end()
	EndIf
	
Return


/////////////////////////////////////////////////
// Descrição leitura do arquivo CSV.
Static function FSIMP003()

	Local cLinha        := "" 
	Local aDados        := {}
	Local cGrava        := ""
	local  cMascara  	:= '*.csv'
	Local nMascpad      := 0
	local  cDirini   	:= "\"
	Local  lSalvar   	:= .T. //.T. = Salva || .F. = Abre
	Local  nOpcoes   	:= GETF_LOCALHARD
	Local  lArvore   	:= .T. //.T. = apresenta o árvore do servidor || .F. = não apresenta
	
	Private cLeARQ      := ''

	cLocalFile	        := cGetFile( cMascara, "Escolha o arquivo", nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
	ADIR(cLocalFile+ "*.csv",aDados)
	
	MV_PAR01 := cLocalFile 
	
	cLeARQ	 := SubStr(MV_PAR01,1,RAT("\",MV_PAR01)) 

	FT_FUSE(MV_PAR01)
	FT_FGOTOP()

	If cLocalFile == "" // caso colocar em cancelar na escolha do arquivo ele sai do programa
		Return
	EndIf

	ProcRegua(10000)
	While !FT_FEOF() 
		IncProc("Preparando arquivo...")
		cLinha := Upper(FT_FREADLN())
		aAdd(aDados,Separa(cLinha,";",.T.))
		FT_FSKIP()
	EndDo

	FT_FUSE()
	If !Len(aDados) > 1
		Alert("A T E N Ç Ã O" + CRLF + CRLF + "Não há dados a ser importado")
		Return
	EndIf

	FSIMP004(aDados)

Return

/////////////////////////////////////////////////
// Verifica o ultimo registro do item.
Static Function MaiorItem(cCodTab)

	Local cMAIOR 	:= ''
	Local cQuery 	:=	''
	Local cAlias	:= GetNextAlias()

	cQuery += " SELECT ISNULL(MAX(DA1_ITEM),'0000') MAIOR FROM "+ retsqlname("DA1")
	cQuery += "  WHERE DA1_FILIAL = '"+xFilial("DA1")+"'"
	cQuery += "   and DA1_CODTAB = '"+cCodTab+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	(cAlias)->(dbGoTop())
	cMAIOR := (cAlias)->MAIOR 
	(cAlias)->(dbCloseArea())

Return cMAIOR


/////////////////////////////////////////////////
// Inclui/Altera Item
Static Function FSIMP004(aDados)

	Local _loop     := 0
	Local cMsgErro  := ''
	Local cScript   := ''

	// Exclui os itens deletados
	cScript := "DELETE " + RetSqlName("DA0") + " WHERE D_E_L_E_T_ = '*' "
	TCSqlExec(cScript)

	cScript := "DELETE " + RetSqlName("DA1") + " WHERE D_E_L_E_T_ = '*' "
	TCSqlExec(cScript)

	//ADel(aDados,1) // tratamento para excluir primeira linha do array
	//ASize( aDados,LEN(aDados)-1) // tratamento para excluir a linha em branco do array
	//aSort(aDados, , , {|x, y| x[1] < y[1]}) // Ordenar 

	If Alltrim(UPPER(aDados[1,1])) <> 'COD. TABELA'

		cMsgErro += "Status: LAYOUT INVALIDO" + CRLF
	
	Else
	
		cCodTab := ""
		ProcRegua(Len(aDados))
		For _loop := 1 To Len(aDados)
			
			IncProc("Processando...")
	
			If Empty(aDados[_loop,1]) 
			   Exit
			endif
			
			If Alltrim(aDados[_loop,1]) <> 'COD. TABELA'
			
				If !(cCodTab == aDados[_loop,1])
	
					cCodTab := aDados[_loop,1]				
	
					DBSelectArea("DA0")
					DA0->(DbSetOrder(1))
					DA0->(DBGoTop())
					If !DA0->(dbseek(xFilial("DA0")+cCodTab))				
						RecLock("DA0", .T.)	
						DA0->DA0_FILIAL := xFilial("DA0")
						DA0->DA0_CODTAB := cCodTab
						DA0->DA0_DESCRI := "TABELA DE PREÇO: "+ cCodTab
						DA0->DA0_DATDE  := dDataBase
						DA0->DA0_HORADE := "00:00"
						DA0->DA0_DATATE := dVigencia
						DA0->DA0_HORATE := "23:59"
						DA0->DA0_TPHORA := "1"
						DA0->DA0_ATIVO  := "1"
						DA0->(MsUnLock())	
					endif
				
				EndIf
		
				DBSelectArea("SB1")
				SB1->(DBSetOrder(1))
				SB1->(DBGoTop())
				If SB1->(dbseek(xFilial("SB1")+ aDados[_loop,2]))
		
					DBSelectArea("DA1")
					DA1->(DBSetOrder(1))
					DA1->(DBGoTop())
					If !DA1->(dbseek(xFilial("DA1") + aDados[_loop,1] + aDados[_loop,2] + SPACE(TAMSX3("DA1_CODPRO")[1]-LEN(aDados[_loop,2])) ))				
	
						cMsgErro += "Status: INCLUIDO;" + " Tabela: "+ALLTRIM(aDados[_loop,1]) + ";Produto: " +ALLTRIM(aDados[_loop,2]) + ";Valor: " + ALLTRIM(aDados[_loop,3]) + CRLF
	
						RecLock("DA1", .T.)	
						DA1->DA1_FILIAL := xFilial("DA1")
						DA1->DA1_ITEM   := Soma1(MaiorItem(cCodTab))
	
					else
	
						cMsgErro += "Status: ALTERADO;" + " Tabela: "+ALLTRIM(aDados[_loop,1]) + ";Produto: " +ALLTRIM(aDados[_loop,2]) + ";Valor: " + ALLTRIM(aDados[_loop,3]) + CRLF
						
						RecLock("DA1", .F.)	
						DA1->DA1_FILIAL := xFilial("DA1")
		
					endif
		
					DA1->DA1_CODTAB := ALLTRIM(aDados[_loop,1])
					DA1->DA1_CODPRO := ALLTRIM(aDados[_loop,2])
					If Valtype(aDados[_loop,3]) <> "N"
						DA1->DA1_PRCVEN := VAL(aDados[_loop,3])
					Else
						DA1->DA1_PRCVEN := aDados[_loop,3]
					EndIf	
					DA1->DA1_ATIVO  := "1"
					DA1->DA1_TPOPER := '4'
					DA1->DA1_QTDLOT := 999999.99
					DA1->DA1_INDLOT := '000000000999999.99'
					DA1->DA1_MOEDA  := 1
					DA1->DA1_DATVIG := dVigencia
					DA1->DA1_DTUMOV := dDataBase
					DA1->DA1_HRUMOV := substr(TIME(),1,5)
					DA1->(MsUnLock())	
		
				Else
		
					cMsgErro += "Status: PRODUTO NÃO CADASTRADO; " + "Tabela: "+ALLTRIM(aDados[_loop,1]) + ";Produto: " +ALLTRIM(aDados[_loop,2]) + ";Valor: " + ALLTRIM(aDados[_loop,3]) + CRLF
		
				EndIf
			
			else
				cMsgErro += "Status: LINHA IGNORADO;" + " Tabela: "+ALLTRIM(aDados[_loop,1]) + ";Produto: " +ALLTRIM(aDados[_loop,2]) + ";Valor: " + ALLTRIM(aDados[_loop,3]) + CRLF
			Endif
		
		Next
	
	endif
	
	FSIMP005(cMsgErro)//Função de geração de log	

Return


/////////////////////////////////////////////////
// Geração de arquivos do log com CSV.
Static function FSIMP005(cMsgErro)

	Local nHandle 
	Local nBloco := 999999
	Local nI := 0
	Local cBuffer := '' 
	Local nRet := MakeDir(cLeARQ)
   
	if nRet != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar(FError()))
	endif

	MakeDir(cLeARQ)
	nHandle := FCreate(cLeARQ+cArquivo)
	cBuffer += cMsgErro + CRLF
	FWrite(nHandle, cBuffer,nBloco )
	FClose(nHandle)
	
	If Len(cMsgErro) >0
		MsgInfo("A T E N Ç Ã O" + CRLF + CRLF + "Foi gerado um Log do(s) resgistro(s) processados no mesmo diretório do arquivo .CSV","LOG ARQUIVO")
	EndIf

Return .T.

#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'TOPCONN.ch'
#Include 'FWMVCDef.ch'
#Include 'SHELL.ch'
#INCLUDE "TBICONN.CH"
#include "fileio.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} 
    Rotina de Alinhamento de Tabelas de Saldos Iniciais Fisico Financeiro e Saldos iniciais por lote
    Como Parâmetro irá assumir os saldos dos saldos por lote SBJ
    @type Function
    @author Leandro Schumann Thomaz
    @since 11/02/2021
    @version P12
    @obs Uso AVACY CALÇADOS 
/*/

User Function BALLOTE()

    Local cQuery    :=""
    Local cPerg     := "BALLOTE"

    AjustaSX1(cPerg)


    If pergunte(cPerg,.T.,"Balanceamento SB9 com dados da SBJ")
        cQuery += " SELECT B1_COD COD FROM SB1010 "       
        cQuery += " WHERE D_E_L_E_T_ = ' ' AND B1_RASTRO = 'L' " // Pego produtos com controle de lote
        If !Empty(mv_par02)
            cQuery += " AND B1_COD = '" +      mv_par02  + "' "        
        Endif
        cQuery += " ORDER BY B1_FILIAL, B1_COD " 
        
        
        
        cQuery := ChangeQuery(cQuery)


        RptStatus({|| ExecFun(cQuery,DTOS(MV_PAR01))}, "Aguarde...", "Ajustando SB9 ...")
    Endif


Return

Static Function ExecFun(cQuery,cDataFech)

    Local xAlias    := GetNextAlias()
    Local nLoc01    := 0
    Local nLoc02    := 0
    Local nErro     := 0
    Local cPrdErro  :=""
    Local nAtual    := 0 
    Local nTotal    := 0 
    
    Local nRegAltA1  := 0
    Local nRegAltA2  := 0

    Default cQuery :=""
    Default cDataFech := ""


    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),xAlias,.t.,.t.)

    nHandle := FCREATE("C:\LOG\LOG_AVACY.txt") // crio Arquivo LOG

    if nHandle = -1
        alert("Erro ao criar arquivo - ferror " + Str(Ferror()))
        return
    endif
    FWrite(nHandle, "Inicio do Processamento: "+Time() + CRLF)
    
    Count To nTotal
    SetRegua(nTotal)

    DBSelectArea(xAlias)
    (xAlias)->(dbgotop())
    While (xAlias)->(!Eof()) // roda produtos   
        nAtual++
        IncRegua(nAtual)


        nLoc01:= 0  // zero contagem armazem 01
        nLoc02:= 0  // zero contagem armazem 02
        nErro := 0
        cPrdErro:=""
        DBSelectArea("SBJ")
        DbSetOrder(1) //BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+BJ_NUMLOTE+DTOS(BJ_DATA)
        SBJ->(Dbgotop())
        If dbSeek(xFilial("SBJ")+(xAlias)->COD)
            While SBJ->(!EOF()) .AND. SBJ->BJ_COD == (xAlias)->COD .and. SBJ->BJ_FILIAL == xFilial("SBJ") 
                If SBJ->BJ_DATA == STOD(cDataFech) 
                    If SBJ->BJ_LOCAL == "01" // Tem somente 02 armazéns
                        nLoc01:= nLoc01 + SBJ->BJ_QINI
                    ElseIf SBJ->BJ_LOCAL == "02"
                        nLoc02:= nLoc02 + SBJ->BJ_QINI
                    Else 
                        cPrdErro:= SBJ->BJ_COD
                        nErro:= nErro + SBJ->BJ_QINI
                    Endif
                Endif
                DBSelectArea("SBJ")
                ("SBJ")->(dbSkip())
            EndDo
            If nErro > 0 
                FWrite(nHandle, Time()+ " Produto: "+cPrdErro+" com "+" "+STR(nErro)+" itens com armazém diferente de 01 e 02." + CRLF)
            Endif
            xAlias2:= GetNextAlias()
            cQry :=""
            cQry += " SELECT B9_COD, B9_LOCAL,B9_DATA FROM SB9010 "       
            cQry += " WHERE D_E_L_E_T_ = ' ' AND B9_FILIAL = '"+xFilial("SB9")+"' AND B9_DATA = '"+cDataFech+"' AND  B9_COD = '"+(xAlias)->COD+"' "
            
            dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),xAlias2,.t.,.t.)
            DBSelectArea(xAlias2)
            (xAlias2)->(dbgotop())
            While (xAlias2)->(!Eof()) 
                DBSelectArea("SB9")
                DbSetOrder(1)//B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
                SB9->(dbGotop())
                If dbSeek(xFilial("SB9")+(xAlias2)->B9_COD+(xAlias2)->B9_LOCAL+(xAlias2)->B9_DATA)
                    If SB9->B9_LOCAL == "01" // para armazém 01

                        If nLoc01 <> SB9->B9_QINI  // altero somente se for diferente do que já está na SB9
                            nRegAltA1++
                            nQiniAnt    := 0
                            nCM1Ant     := 0
                            nVini1Ant   := 0
                            nCustoAnt   := 0 
                            nValorNew   := 0
                            
                            // pego valores anteriores 

                            nQiniAnt    := SB9->B9_QINI
                            nCM1Ant     := SB9->B9_CM1
                            nVini1Ant   := SB9->B9_VINI1

                            // calculo novos valores a partir da SBJ

                            nCustoAnt:= nVini1Ant/nQiniAnt
                            nValorNew:= nCustoAnt*nLoc01

                            // Alimento LOG
                            FWrite(nHandle, Time() + CRLF)
                            FWrite(nHandle, "Produto            : "+alltrim(SB9->B9_COD)    + CRLF)
                            FWrite(nHandle, "Armazém            : "+alltrim(SB9->B9_LOCAL)  + CRLF)
                            FWrite(nHandle, "Quant.Anterior     : "+alltrim(STR(nQiniAnt))  + CRLF)
                            FWrite(nHandle, "Custo.SB9 Anterior : "+alltrim(STR(nCM1Ant))   + CRLF)
                            FWrite(nHandle, "Custo.Calculado ant: "+alltrim(STR(nCustoAnt)) + CRLF)
                            FWrite(nHandle, "Valor.Anterior     : "+alltrim(STR(nVini1Ant)) + CRLF)

                            FWrite(nHandle, "Quant.Nova         : "+alltrim(STR(nLoc01))    + CRLF)
                            FWrite(nHandle, "Custo.Novo         : "+alltrim(STR(nCustoAnt)) + CRLF)
                            FWrite(nHandle, "Valor.Novo         : "+alltrim(STR(nValorNew)) + CRLF+ CRLF)

                            RecLock("SB9",.F.)
                            SB9->B9_QINI   := nLoc01
                            SB9->B9_VINI1  := nValorNew
                            SB9->B9_CM1    := nCustoAnt
                            SB9->(MsUnLock())
                        Endif

                    ElseIf SB9->B9_LOCAL == "02" // para armazém 02
                        nRegAltA2++
                        If nLoc02 <> SB9->B9_QINI  // altero somente se for diferente do que já está na SB9
                            nQiniAnt    := 0
                            nCM1Ant     := 0
                            nVini1Ant   := 0
                            nCustoAnt   := 0 
                            nValorNew   := 0
                            
                            // pego valores anteriores 

                            nQiniAnt    := SB9->B9_QINI
                            nCM1Ant     := SB9->B9_CM1
                            nVini1Ant   := SB9->B9_VINI1

                            // calculo novos valores a partir da SBJ

                            nCustoAnt:= nVini1Ant/nQiniAnt
                            nValorNew:= nCustoAnt*nLoc02

                            // Alimento LOG
                            FWrite(nHandle, Time() + CRLF)
                            FWrite(nHandle, "Produto            : "+alltrim(SB9->B9_COD)    + CRLF)
                            FWrite(nHandle, "Armazém            : "+alltrim(SB9->B9_LOCAL)  + CRLF)
                            FWrite(nHandle, "Quant.Anterior     : "+alltrim(STR(nQiniAnt))  + CRLF)
                            FWrite(nHandle, "Custo.SB9 Anterior : "+alltrim(STR(nCM1Ant))   + CRLF)
                            FWrite(nHandle, "Custo.Calculado ant: "+alltrim(STR(nCustoAnt)) + CRLF)
                            FWrite(nHandle, "Valor.Anterior     : "+alltrim(STR(nVini1Ant)) + CRLF)

                            FWrite(nHandle, "Quant.Nova         : "+alltrim(STR(nLoc02))    + CRLF)
                            FWrite(nHandle, "Custo.Novo         : "+alltrim(STR(nCustoAnt)) + CRLF)
                            FWrite(nHandle, "Valor.Novo         : "+alltrim(STR(nValorNew)) + CRLF+ CRLF)

                            RecLock("SB9",.F.)
                            SB9->B9_QINI   := nLoc02
                            SB9->B9_VINI1  := nValorNew
                            SB9->B9_CM1    := nCustoAnt
                            SB9->(MsUnLock())
                        Endif
                    Else 

                        FWrite(nHandle, Time() + CRLF)
                        FWrite(nHandle, "Produto: "+SB9->B9_COD +" Não pertence a armazém 01 ou 02, verificar!"    +CRLF+CRLF)

                    Endif
                Else
                    FWrite(nHandle, Time() + CRLF)
                    FWrite(nHandle, "NÃO LOCALIZOU PRODUTO: "+(xAlias)->COD+" NA TABELA SB9. "    +CRLF+CRLF)

                Endif

                DBSelectArea(xAlias2)
                (xAlias2)->(dbSkip())
            EndDo
            (xAlias2)->(dbCloseArea())
        //Else Ignorado pois muitos produtos foram somente cadastrados e não tem saldo inicial
            //FWrite(nHandle, Time() + CRLF) 
            //FWrite(nHandle, "NÃO LOCALIZOU PRODUTO: "+(xAlias)->COD+" NA TABELA SBJ. "    +CRLF+CRLF)
        Endif 
        DBSelectArea(xAlias)
        (xAlias)->(dbSkip())
    EndDo
    (xAlias)->(dbCloseArea())

    FWrite(nHandle, "Registros Alterados Armazém 01: "+ STR(nRegAltA1) + CRLF) 
    FWrite(nHandle, "Registros Alterados Armazém 02: "+ STR(nRegAltA2) + CRLF) 
    FWrite(nHandle, "Fim do Processamento: "+Time() + CRLF)

    FClose(nHandle) // fecho arquivo de log


Return

Static Function AjustaSx1(cPerg)


xPutSx1(cPerg,"01","Data do Fechamento"           ,"","","mv_ch1","D",08,0,0,"G",""               ,""   ,""   ,"","mv_par01","","","","","","")
xPutSx1(cPerg,"02","Produto Específico ?"         ,"","","mv_ch2","C",15,0,0,"G",""               ,"SB1","","","mv_par02","","","","","","")

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .F.
	Local lSpa  := .F.
	Local lIngl := .F.
	
	


	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
	cF3      := Iif( cF3           == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
	cHelp    := Iif( cHelp          == Nil, "" , cHelp          )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"               // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return


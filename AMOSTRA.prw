#INCLUDE "Protheus.ch"

////////////////////////
User Function Amostra()   

Local aArea    := GetArea() 
Local cPorta   := "LPT2"
Local cModelo  := "ZEBRA"
Local cCodGd1  := ""
Local cCodGd2  := ""
Local cQuery   := ""
Local cAliGrd  := GetNextAlias()
Local cAliGrd2 := GetNextAlias()
Local cDesGrd1 := ""
Local cDesc1   := ""
Local cDesc2   := ""
Local cDesc3   := ""
Local cQtd1     := ""
Local aTamNum  := Array(2,12)
Local cDesGrd2 := ""
Local cDesc1s  := ""
Local cDesc2s  := ""
Local cDesc3s  := ""
Local cQtd2    := ""
Local aTamNum2 := Array(2,12)
Local nX       := 0
Local aPWiz    := {}
Local aRetWiz  := {}
Local cLote1   := ""
Local cLote2   := ""
Local nVlrUni1 := 0
Local nVlrUni2 := 0
Local nVlrTot1 := 0
Local nVlrTot2 := 0
Local lRet	   := .T.

aAdd(aPWiz,{ 1,"Grade 1: "               ,Space(TamSX3("Z01_LOTE")[1])     ,"","","Z01A","",    ,.T.})
aAdd(aPWiz,{ 1,"Grade 2: "               ,Space(TamSX3("Z01_LOTE")[1])     ,"","","Z01A",  ,    ,.T.})

aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))

lRet:= ParamBox(aPWiz,"Etiqueta Amostra - Grade Avacy",@aRetWiz,,,,,,) 

If !lRet
	RestArea( aArea )
	Return
EndIf

cCodGd1   := Alltrim(aRetWiz[1])
cCodGd2   := Alltrim(aRetWiz[2]) 

cQuery := "SELECT Z01_GRADE," 
cQuery += " Z01_QTD," 
cQuery += " Z01_LOTE," 
cQuery += " Z02_CODGRD," 
cQuery += " Z02_COD," 
cQuery += " Z02_QTD," 
cQuery += " Z02_NUM,"
cQuery += "( SELECT DA1_PRCVEN FROM "+ RetSqlName("DA1")+ " WHERE DA1_CODTAB = '001' AND DA1_CODPRO = Z02_COD AND "+RetSqlName("DA1")+".D_E_L_E_T_ = ' ' ) DA1_PRCVEN "  
cQuery += "FROM " + RetSqlName("Z02")+ " "
cQuery += "INNER JOIN " + RetSqlName("Z01")+ " "
cQuery += "ON Z01_LOTE = Z02_CODGRD" 
cQuery += "WHERE  Z01_LOTE = '" + cCodGd1 + "' " 
cQuery += "AND "+RetSqlName("Z02")+".D_E_L_E_T_ = ' '" 
cQuery += "AND "+RetSqlName("Z01")+".D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY Z02_NUM" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd,.T.,.T.)

(cAliGrd)->(dbGoTop())

cDesGrd1:= UPPER(Alltrim((cAliGrd)->Z01_GRADE))
cLote1  := Alltrim((cAliGrd)->Z01_LOTE)
cDesc1  := alltrim(SUBSTR(cDesGrd1,01,23)) 
cDesc2  := alltrim(SUBSTR(cDesGrd1,24,23)) 
cDesc3  := alltrim(SUBSTR(cDesGrd1,47,24)) 
cQtd1   := Alltrim((cAliGrd)->Z01_QTD)
nVlrUni1:= Alltrim(Transform((cAliGrd)->DA1_PRCVEN,"@E 999,999.99"))

For nX := 1 To 12
	
	aTamNum[1][nX]:= Alltrim((cAliGrd)->Z02_NUM)
	aTamNum[2][nX]:= Alltrim((cAliGrd)->Z02_QTD)
	
	(cAliGrd)->(DbSkip()) 
		
Next

(cAliGrd)->(dbGoTop())

Do While (cAliGrd)->(!Eof())
	
	nVlrTot1 += (cAliGrd)->DA1_PRCVEN * Val((cAliGrd)->Z02_QTD)
	(cAliGrd)->(DbSkip()) 
		
EndDo

nVlrTot1 := Alltrim(Transform(nVlrTot1,"@E 999,999.99")) 

(cAliGrd)->(DbCloseArea())

//Inicio a segunda query para a segunda etiqueta

cQuery := "SELECT Z01_GRADE," 
cQuery += " Z01_QTD," 
cQuery += " Z01_LOTE," 
cQuery += " Z02_CODGRD," 
cQuery += " Z02_COD," 
cQuery += " Z02_QTD," 
cQuery += " Z02_NUM,"
cQuery += "( SELECT DA1_PRCVEN FROM "+ RetSqlName("DA1")+ " WHERE DA1_CODTAB = '001' AND DA1_CODPRO = Z02_COD AND "+RetSqlName("DA1")+".D_E_L_E_T_ = ' ' ) DA1_PRCVEN "  
cQuery += "FROM " + RetSqlName("Z02")+ " "
cQuery += "INNER JOIN " + RetSqlName("Z01")+ " "
cQuery += "ON Z01_LOTE = Z02_CODGRD" 
cQuery += "WHERE  Z01_LOTE = '" + cCodGd2 + "' " 
cQuery += "AND "+RetSqlName("Z02")+".D_E_L_E_T_ = ' '" 
cQuery += "AND "+RetSqlName("Z01")+".D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY Z02_NUM" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd2,.T.,.T.)

(cAliGrd2)->(dbGoTop())

cDesGrd2 := UPPER(Alltrim((cAliGrd2)->Z01_GRADE))
cLote2   := Alltrim((cAliGrd2)->Z01_LOTE)
cDesc1s  := alltrim(SUBSTR(cDesGrd2,01,23)) 
cDesc2s  := alltrim(SUBSTR(cDesGrd2,24,23)) 
cDesc3s  := alltrim(SUBSTR(cDesGrd2,47,24)) 
cQtd2    := Alltrim((cAliGrd2)->Z01_QTD)
nVlrUni2 := Alltrim(Transform((cAliGrd2)->DA1_PRCVEN,"@E 999,999.99"))  // picture 

For nX := 1 To 12
	
	aTamNum2[1][nX]:= Alltrim((cAliGrd2)->Z02_NUM)
	aTamNum2[2][nX]:= Alltrim((cAliGrd2)->Z02_QTD)

	(cAliGrd2)->(DbSkip()) 
		
Next 

(cAliGrd2)->(dbGoTop())

Do While (cAliGrd2)->(!Eof())

	nVlrTot2 += (cAliGrd2)->DA1_PRCVEN * Val((cAliGrd2)->Z02_QTD)
	(cAliGrd2)->(DbSkip()) 
		
EndDo

nVlrTot2 := Alltrim(Transform(nVlrTot2,"@E 999,999.99"))

(cAliGrd2)->(DbCloseArea())

MSCBPrinter(cModelo, cPorta, NIL, NIL, .F., NIL, NIL, NIL, , NIL, .F.) 
MSCBChkStatus(.F.)    

MSCBBEGIN(1,6)
MSCBWRITE("^XA")
MSCBWRITE("^MMT")
MSCBWRITE("^PW831")
MSCBWRITE("^LL0599")
MSCBWRITE("^LS0") 

// PARTE 1 (ESQUERDA)

MSCBWRITE("^FO440,370^GB334,100,4^FS")
MSCBWRITE("^FO440,420^GB334,000,2^FS")

MSCBWRITE("^FO490,370^GB0,95,1^FS")
MSCBWRITE("^FO540,370^GB0,95,1^FS")
MSCBWRITE("^FO590,370^GB0,95,1^FS")
MSCBWRITE("^FO640,370^GB0,95,1^FS")
MSCBWRITE("^FO690,370^GB0,95,1^FS")
MSCBWRITE("^FO740,370^GB0,95,1^FS")

MSCBWRITE("^FO440,250^GB334,100,4^FS")
MSCBWRITE("^FO440,300^GB334,000,2^FS")

MSCBWRITE("^FO490,250^GB0,95,1^FS")
MSCBWRITE("^FO540,250^GB0,95,1^FS")
MSCBWRITE("^FO590,250^GB0,95,1^FS")
MSCBWRITE("^FO640,250^GB0,95,1^FS")
MSCBWRITE("^FO690,250^GB0,95,1^FS")
MSCBWRITE("^FO740,250^GB0,95,1^FS")

MSCBWRITE("^FT786,582^A0I,23,24^FH\^FD  " + cDesc1s + "^FS")
MSCBWRITE("^FT786,554^A0I,23,24^FH\^FD  " + cDesc2s + "^FS")
MSCBWRITE("^FT786,526^A0I,23,24^FH\^FD  " + cDesc3s + "^FS")

MSCBWRITE("^FT786,483^A0I,23,24^FH\^FD  Total de Pares: "+ cQtd2 + "^FS")

MSCBWRITE("^FT786,316^A0I,15,15^FH\^FD    TAM" +"^FS")
MSCBWRITE("^FT786,268^A0I,15,15^FH\^FD    QTD" +"^FS")
MSCBWRITE("^FT743,316^A0I,20,19^FH\^FD " + aTamNum2[1][7] +"^FS")
MSCBWRITE("^FT743,268^A0I,20,19^FH\^FD   " + aTamNum2[2][7] +"^FS")
MSCBWRITE("^FT693,316^A0I,20,19^FH\^FD " + aTamNum2[1][8] +"^FS")
MSCBWRITE("^FT693,268^A0I,20,19^FH\^FD   " + aTamNum2[2][8] +"^FS")
MSCBWRITE("^FT643,316^A0I,20,19^FH\^FD " + aTamNum2[1][9] +"^FS")
MSCBWRITE("^FT643,268^A0I,20,19^FH\^FD   " + aTamNum2[2][9] +"^FS")
MSCBWRITE("^FT593,316^A0I,20,19^FH\^FD " + aTamNum2[1][10] +"^FS")
MSCBWRITE("^FT593,268^A0I,20,19^FH\^FD   " + aTamNum2[2][10] +"^FS")
MSCBWRITE("^FT543,316^A0I,20,19^FH\^FD " + aTamNum2[1][11] +"^FS")
MSCBWRITE("^FT543,268^A0I,20,19^FH\^FD   " + aTamNum2[2][11] +"^FS")
MSCBWRITE("^FT493,316^A0I,20,19^FH\^FD " + aTamNum2[1][12] +"^FS")
MSCBWRITE("^FT493,268^A0I,20,19^FH\^FD   " + aTamNum2[2][12] +"^FS")

MSCBWRITE("^FT786,435^A0I,15,15^FH\^FD    TAM" +"^FS")
MSCBWRITE("^FT786,387^A0I,15,15^FH\^FD    QTD" +"^FS")
MSCBWRITE("^FT743,435^A0I,20,19^FH\^FD " + aTamNum2[1][1] +"^FS")
MSCBWRITE("^FT743,387^A0I,20,19^FH\^FD   " + aTamNum2[2][1] +"^FS")
MSCBWRITE("^FT693,435^A0I,20,19^FH\^FD " + aTamNum2[1][2] +"^FS")
MSCBWRITE("^FT693,387^A0I,20,19^FH\^FD   " + aTamNum2[2][2] +"^FS")
MSCBWRITE("^FT643,435^A0I,20,19^FH\^FD " + aTamNum2[1][3] +"^FS")
MSCBWRITE("^FT643,387^A0I,20,19^FH\^FD   " + aTamNum2[2][3] +"^FS")
MSCBWRITE("^FT593,435^A0I,20,19^FH\^FD " + aTamNum2[1][4] +"^FS")
MSCBWRITE("^FT593,387^A0I,20,19^FH\^FD   " + aTamNum2[2][4] +"^FS")
MSCBWRITE("^FT543,435^A0I,20,19^FH\^FD " + aTamNum2[1][5] +"^FS")
MSCBWRITE("^FT543,387^A0I,20,19^FH\^FD   " + aTamNum2[2][5] +"^FS")
MSCBWRITE("^FT493,435^A0I,20,19^FH\^FD " + aTamNum2[1][6] +"^FS")
MSCBWRITE("^FT493,387^A0I,20,19^FH\^FD   " + aTamNum2[2][6] +"^FS")

MSCBWRITE("^FT786,213^A0I,20,19^FH\^FD  Valor Unitario: " + nVlrUni2 +"^FS")
MSCBWRITE("^FT786,189^A0I,20,19^FH\^FD  Valor Grade: " + nVlrTot2 + "^FS")

MSCBWRITE("^BY2,3,96^FT742,70^BCI,,Y,N")
MSCBWRITE("^FD>;>8" + cLote2 + "^FS")

// PARTE 2 (DIREITA)

MSCBWRITE("^FO040,370^GB334,100,4^FS")
MSCBWRITE("^FO040,420^GB334,000,2^FS") 

MSCBWRITE("^FO090,370^GB0,95,1^FS")
MSCBWRITE("^FO140,370^GB0,95,1^FS")
MSCBWRITE("^FO190,370^GB0,95,1^FS")
MSCBWRITE("^FO240,370^GB0,95,1^FS")
MSCBWRITE("^FO290,370^GB0,95,1^FS")
MSCBWRITE("^FO340,370^GB0,95,1^FS")

MSCBWRITE("^FO040,250^GB334,100,4^FS")
MSCBWRITE("^FO040,300^GB334,000,2^FS")   

MSCBWRITE("^FO090,250^GB0,95,1^FS")
MSCBWRITE("^FO140,250^GB0,95,1^FS")
MSCBWRITE("^FO190,250^GB0,95,1^FS")
MSCBWRITE("^FO240,250^GB0,95,1^FS")
MSCBWRITE("^FO290,250^GB0,95,1^FS")
MSCBWRITE("^FO340,250^GB0,95,1^FS")

MSCBWRITE("^FT388,582^A0I,23,24^FH\^FD  " + cDesc1 + "^FS")
MSCBWRITE("^FT388,554^A0I,23,24^FH\^FD  " + cDesc2 + "^FS")
MSCBWRITE("^FT388,526^A0I,23,24^FH\^FD  " + cDesc3 + "^FS")

MSCBWRITE("^FT388,483^A0I,23,24^FH\^FD  Total de Pares: " + cQtd1 + "^FS")

MSCBWRITE("^FT386,316^A0I,15,15^FH\^FD    TAM" +"^FS")
MSCBWRITE("^FT386,268^A0I,15,15^FH\^FD    QTD" +"^FS")
MSCBWRITE("^FT343,316^A0I,20,19^FH\^FD " + aTamNum[1][7] +"^FS")
MSCBWRITE("^FT343,268^A0I,20,19^FH\^FD   " + aTamNum[2][7] +"^FS")
MSCBWRITE("^FT293,316^A0I,20,19^FH\^FD " + aTamNum[1][8] +"^FS")
MSCBWRITE("^FT293,268^A0I,20,19^FH\^FD   " + aTamNum[2][8] +"^FS")
MSCBWRITE("^FT243,316^A0I,20,19^FH\^FD " + aTamNum[1][9] +"^FS")
MSCBWRITE("^FT243,268^A0I,20,19^FH\^FD   " + aTamNum[2][9] +"^FS")
MSCBWRITE("^FT193,316^A0I,20,19^FH\^FD " + aTamNum[1][10] +"^FS")
MSCBWRITE("^FT193,268^A0I,20,19^FH\^FD   " + aTamNum[2][10] +"^FS")
MSCBWRITE("^FT143,316^A0I,20,19^FH\^FD " + aTamNum[1][11] +"^FS")
MSCBWRITE("^FT143,268^A0I,20,19^FH\^FD   " + aTamNum[2][11] +"^FS")
MSCBWRITE("^FT093,316^A0I,20,19^FH\^FD " + aTamNum[1][12] +"^FS")
MSCBWRITE("^FT093,268^A0I,20,19^FH\^FD   " + aTamNum[2][12] +"^FS")

MSCBWRITE("^FT386,435^A0I,15,15^FH\^FD    TAM" +"^FS")
MSCBWRITE("^FT386,387^A0I,15,15^FH\^FD    QTD" +"^FS")
MSCBWRITE("^FT343,435^A0I,20,19^FH\^FD " + aTamNum[1][1] +"^FS")
MSCBWRITE("^FT343,387^A0I,20,19^FH\^FD   " + aTamNum[2][1] +"^FS")
MSCBWRITE("^FT293,435^A0I,20,19^FH\^FD " + aTamNum[1][2] +"^FS")
MSCBWRITE("^FT293,387^A0I,20,19^FH\^FD   " + aTamNum[2][2] +"^FS")
MSCBWRITE("^FT243,435^A0I,20,19^FH\^FD " + aTamNum[1][3] +"^FS")
MSCBWRITE("^FT243,387^A0I,20,19^FH\^FD   " + aTamNum[2][3] +"^FS")
MSCBWRITE("^FT193,435^A0I,20,19^FH\^FD " + aTamNum[1][4] +"^FS")
MSCBWRITE("^FT193,387^A0I,20,19^FH\^FD   " + aTamNum[2][4] +"^FS")
MSCBWRITE("^FT143,435^A0I,20,19^FH\^FD " + aTamNum[1][5] +"^FS")
MSCBWRITE("^FT143,387^A0I,20,19^FH\^FD   " + aTamNum[2][5] +"^FS")
MSCBWRITE("^FT093,435^A0I,20,19^FH\^FD " + aTamNum[1][6] +"^FS")
MSCBWRITE("^FT093,387^A0I,20,19^FH\^FD   " + aTamNum[2][6] +"^FS")

MSCBWRITE("^FT388,214^A0I,20,19^FH\^FD  Valor Unitario: " + nVlrUni1 + "^FS")
MSCBWRITE("^FT388,190^A0I,20,19^FH\^FD  Valor Grade: " + nVlrTot1 + "^FS")

MSCBWRITE("^BY2,3,96^FT357,80^BCI,,Y,N")
MSCBWRITE("^FD>;>8" + cLote1 + "^FS")

MSCBWRITE("^PQ1,0,1,Y^XZ")
MSCBEND()
MSCBCLOSEPRINTER()

RestArea( aArea )

Return

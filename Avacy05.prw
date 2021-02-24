#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc}Avacy05
Tela de consulta ao estoque por grade - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

User Function Avacy05(cCodigo, nOpt) 

Local cConGrd  := GetNextAlias()

Private oProcess


if nOpt == 1

	if !Empty(cCodigo)
	
		DbSelectArea("SB1")
		If !DbSeek(xFilial("SB1") + cCodigo)
			Alert("Produto: "+cCodigo+" não existe!")
		else
			oProcess := MsNewProcess():New( { || xConSld(cCodigo , nOpt) } , "Realizando consulta de saldo em estoque" , "Aguarde..." , .F. )
			oProcess:Activate()
		endIf
	
	else
	  Alert("Produto não informado!")
	endif

endif

if nOpt == 2

	if !Empty(cCodigo)

		cQuery := "SELECT COUNT(*) QTD "
		cQuery += "  FROM " + RetSqlName("SB8") 
		cQuery += " WHERE B8_FILIAL = '" + xFilial("SB8") + "'"
		cQuery += "   AND B8_LOTECTL = '" + cCodigo + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd,.T.,.T.)
		(cConGrd)->(dbGoTop())
		nQTD := (cConGrd)->QTD
		(cConGrd)->(DbCloseArea())
	
		If nQTD == 0
			Alert("Grade: "+cCodigo+" não existe!")
		else
			oProcess := MsNewProcess():New( { || xConSld(cCodigo , nOpt) } , "Realizando consulta de saldo em estoque" , "Aguarde..." , .F. )
			oProcess:Activate()
		endIf
	
	else
	  Alert("Grade não informado!")
	endif

endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Avacy05
Tela de consulta ao estoque por grade - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xConSld(cCodigo, nOpt) 

Local aCoors    := FWGetDialogSize( oMainWnd ) 
Local cQuery    := ""
Local cGrade    := ""
Local cConCab   := GetNextAlias()

Local cConGrd1  := GetNextAlias()
Local cConGrd2  := GetNextAlias()
Local cConGrd3  := GetNextAlias()
Local aColumns  := {}
Local aColGrd1  := {}
Local aColGrd2  := {}
Local nX        := 0
Local aCampos   := {}
Local aCpsGrd1  := {}
Local aCpsGrd2  := {}

Local _oConGrd1 
Local _oConGrd2

Local oBrowseSup
Local oBrowseInf

Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oRelac

Private oDlgPrinc 
Private aRotina 	:=	MenuDef()
Private nTotCxLt    := 0 

if nOpt == 1
   AADD(aCpsGrd1,{"FILIAL"       ,"C",TamSX3("Z02_FILIAL")[1] ,0})
   AADD(aCpsGrd1,{"COD"          ,"C",TamSX3("Z02_COD")[1]    ,0})
   AADD(aCpsGrd1,{"DESCR"        ,"C",120                     ,0})
   AADD(aCpsGrd1,{"OBS"          ,"C",1						  ,0})
endif

if nOpt == 2
   AADD(aCpsGrd1,{"FILIAL"       ,"C",TamSX3("Z02_FILIAL")[1] ,0})
   AADD(aCpsGrd1,{"CODGRD"       ,"C",TamSX3("Z02_COD")[1]    ,0})
   AADD(aCpsGrd1,{"OBS"          ,"C",1						  ,0})
endif

AADD(aCpsGrd2,{"FILIAL"          ,"C",TamSX3("Z02_FILIAL")[1] ,0})
AADD(aCpsGrd2,{"COD"             ,"C",TamSX3("Z02_COD")[1]    ,0})
AADD(aCpsGrd2,{"CODGRD"          ,"C",TamSX3("Z02_CODGRD")[1] ,0})
AADD(aCpsGrd2,{"NUM"             ,"C",TamSX3("Z02_NUM")[1]    ,0})
AADD(aCpsGrd2,{"QTD"	      `  ,"N",9						  ,0})
AADD(aCpsGrd2,{"SALDO"           ,"N",9						  ,0})
AADD(aCpsGrd2,{"CAIXA"           ,"N",9						  ,2})
AADD(aCpsGrd2,{"OBS"             ,"C",1						  ,0})

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

if nOpt == 1
	cQuery := " SELECT Z02_FILIAL, Z02_COD FROM " + RetSqlName('Z02')  
	cQuery += "  WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
	cQuery += "    AND Z02_COD = '" + cCodigo + "'"
	cQuery += "    AND D_E_L_E_T_ = ' '"
endif

if nOpt == 2
	cQuery := " SELECT Z02_FILIAL, Z02_CODGRD FROM " + RetSqlName('Z02')  
	cQuery += "  WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
	cQuery += "    AND Z02_CODGRD = '" + cCodigo + "'"
	cQuery += "    AND D_E_L_E_T_ = ' '"
endif

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd1,.T.,.T.)
(cConGrd1)->(dbGoTop())

oProcess:SetRegua1( (cConGrd1)->(RecCount()) ) 

If _oConGrd1 <> Nil
	_oConGrd1:Delete() 
	_oConGrd1 := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConGrd1 := FwTemporaryTable():New("cArqGrd1")

// Criando a estrutura do objeto  
_oConGrd1:SetFields(aCpsGrd1)

// Criando o indice da tabela
if nOpt == 1
	_oConGrd1:AddIndex("1",{"COD"})
endif
if nOpt == 2
	_oConGrd1:AddIndex("1",{"CODGRD"})
endif

_oConGrd1:Create()

oProcess:IncRegua2("Consultando Grades...")

if nOpt == 1
	RecLock("cArqGrd1",.T.)
	cArqGrd1->FILIAL  := (cConGrd1)->Z02_FILIAL
	cArqGrd1->COD     := (cConGrd1)->Z02_COD
	cArqGrd1->DESCR   := xDescPro((cConGrd1)->Z02_COD)
	cArqGrd1->OBS     := "."
	MsUnLock()
endif

if nOpt == 2
	RecLock("cArqGrd1",.T.)
	cArqGrd1->FILIAL  := (cConGrd1)->Z02_FILIAL
	cArqGrd1->CODGRD  := (cConGrd1)->Z02_CODGRD
	cArqGrd1->OBS     := "."
	MsUnLock()
endif
	
cArqGrd1->(dbGotop())

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

if nOpt == 1
	cQuery := "SELECT * FROM " + RetSqlName('Z02') + " Z02_B" 
	cQuery += " WHERE Z02_B.Z02_COD = '" + cCodigo + "'"
	cQuery += "   AND Z02_B.Z02_CODGRD IN ( " 
	cQuery += "                              SELECT DISTINCT Z02_CODGRD FROM " + RetSqlName('Z02') + " Z02_A" 
	cQuery += "                               WHERE Z02_A.Z02_COD = '" + cCodigo + "'"
	cQuery += "                                 AND Z02_A.D_E_L_E_T_ = ' '"
	cQuery += "                            ) "
	cQuery += "  AND Z02_B.D_E_L_E_T_ = ' '"
endif

if nOpt == 2
	cQuery := "SELECT * FROM " + RetSqlName('Z02') + " Z02_B" 
	cQuery += " WHERE Z02_B.Z02_CODGRD IN ( " 
	cQuery += "                              SELECT DISTINCT Z02_CODGRD FROM " + RetSqlName('Z02') + " Z02_A" 
	cQuery += "                               WHERE Z02_A.Z02_CODGRD = '" + cCodigo + "'"
	cQuery += "                                 AND Z02_A.D_E_L_E_T_ = ' '"
	cQuery += "                            ) "
	cQuery += "  AND Z02_B.D_E_L_E_T_ = ' '"
endif

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd2,.T.,.T.)
(cConGrd2)->(dbGoTop())

If _oConGrd2 <> Nil
	_oConGrd2:Delete() 
	_oConGrd2 := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConGrd2 := FwTemporaryTable():New("cArqGrd2")

// Criando a estrutura do objeto  
_oConGrd2:SetFields(aCpsGrd2)

// Criando o indice da tabela
if nOpt == 1
	_oConGrd2:AddIndex("1",{"COD"})
endif
if nOpt == 2
	_oConGrd2:AddIndex("1",{"CODGRD"})
endif

_oConGrd2:Create()

oProcess:SetRegua2( (cConGrd2)->(RecCount()) ) 

Do While (cConGrd2)->(!Eof())

	oProcess:IncRegua1("Processando consulta de saldo por lote")

	cQuery := "SELECT ISNULL(B8_SALDO,0) B8_SALDO "
	cQuery += "  FROM " + RetSqlName("SB8") 
	cQuery += " WHERE B8_FILIAL = '" + xFilial("SB8") + "'"
	cQuery += "   AND B8_PRODUTO = '" + (cConGrd2)->Z02_COD + "'"
	cQuery += "   AND B8_LOTECTL = '" + (cConGrd2)->Z02_CODGRD + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd3,.T.,.T.)
	(cConGrd3)->(dbGoTop())
	nSALDO := (cConGrd3)->B8_SALDO
	(cConGrd3)->(DbCloseArea())

	RecLock("cArqGrd2",.T.)
	cArqGrd2->FILIAL      := (cConGrd2)->Z02_FILIAL 
	cArqGrd2->CODGRD      := (cConGrd2)->Z02_CODGRD  
	cArqGrd2->COD         := (cConGrd2)->Z02_COD
	cArqGrd2->NUM         := (cConGrd2)->Z02_NUM
	cArqGrd2->QTD  		  := VAL((cConGrd2)->Z02_QTD)
	cArqGrd2->SALDO		  := nSALDO
	if nSALDO  > 0 
		cArqGrd2->CAIXA   := nSALDO / VAL((cConGrd2)->Z02_QTD) 
	else
		cArqGrd2->CAIXA   := 0
	endif
	cArqGrd2->OBS		  := "."

	MsUnLock()
	
	(cConGrd2)->(DbSkip())
		
EndDo

cArqGrd2->(dbGotop())

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////


Define MsDialog oDlgPrinc Title 'Consulta de Estoque' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel 

// 
// Cria o conteiner onde serão colocados os browses 

// 
oFWLayer := FWLayer():New() 
oFWLayer:Init( oDlgPrinc, .F., .T. ) 

//  
// Define Painel Superior 
// 
oFWLayer:AddLine( 'UP', 50, .F. ) 
// Cria uma "linha" com 50% da tela 
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) 
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela 
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' ) 
// Pego o objeto desse pedaço do container 

// 
// Painel Inferior 
// 
oFWLayer:AddLine( 'DOWN', 50, .F. ) 
oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' ) 
oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaço esquerdo 

// 
// FWmBrowse Superior 
// 
oBrowseUp:= FWmBrowse():New() 
oBrowseUp:DisableReport()
oBrowseUp:SetOwner( oPanelUp ) 
if nOpt == 1
	oBrowseUp:SetDescription( "Produto selecionado" ) 
endif
if nOpt == 2
	oBrowseUp:SetDescription( "Grade selecionado" ) 
endif

oBrowseUp:SetAlias( 'cArqGrd1') 

if nOpt == 1
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->FILIAL"	,"Filial"		  ,01,"@!",0,010,0))
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->COD"		,"Produto"		  ,02,"@!",0,010,0))
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->DESCR"		,"Descricao"      ,04,"@!",0,050,0))
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->OBS"		,"." 			  ,05,"@!",0,050,0))
endif
if nOpt == 2
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->FILIAL"	,"Filial"		  ,01,"@!",0,010,0))
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->CODGRD"	,"Grupo"		  ,02,"@!",0,010,0))
	oBrowseUp:SetColumns(MontaColunas("cArqGrd1->OBS"		,"." 			  ,03,"@!",0,050,0))
endif

oBrowseUp:SetMenuDef( '' ) 
oBrowseUp:SetProfileID( '1' ) 
oBrowseUp:ForceQuitButton() 
oBrowseUp:Activate() 

// 
// FWmBrowse Inferior 
// 
oBrowseDown:= FWMBrowse():New() 
oBrowseDown:DisableReport()
oBrowseDown:SetOwner( oPanelLeft ) 
if nOpt == 1
   oBrowseDown:SetDescription( 'Todas as Grades do Produto Selecionado' ) 
endif
if nOpt == 2
   oBrowseDown:SetDescription( 'Todos os Produtos da Grade Selecioanda' ) 
endif

oBrowseDown:SetAlias( 'cArqGrd2' ) 

oBrowseDown:AddLegend( "cArqGrd2->SALDO > 0"   , "GREEN" ,"Produto em estoque" ) 
oBrowseDown:AddLegend( "cArqGrd2->SALDO <= 0"  , "RED"  ,"Produto sem estoque" ) 

if nOpt == 1
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->FILIAL"		,"Filial"		      ,01,"@!",0,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->CODGRD"	    ,"Grade"	      	  ,02,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->NUM"	        ,"Numero"	          ,03,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->QTD"			,"Quantidade"	      ,04,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->SALDO"		,"Saldo"	     	  ,05,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->CAIXA"		,"Caixa"	     	  ,06,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->OBS"		    ,"."		     	  ,07,"@!",1,010,0))
endif
if nOpt == 2
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->FILIAL"		,"Filial"		      ,01,"@!",0,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->COD"	    	,"Produto"	      	  ,02,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->NUM"	        ,"Numero"	          ,03,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->QTD"			,"Quantidade"	      ,04,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->SALDO"		,"Saldo"	     	  ,05,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->CAIXA"		,"Caixa"	     	  ,06,"@!",1,010,0))
	oBrowseDown:SetColumns(MontaColunas("cArqGrd2->OBS"		    ,"."		     	  ,07,"@!",1,010,0))
endif
	
oBrowseDown:SetMenuDef( '' ) 
oBrowseDown:SetProfileID( '2' ) 
oBrowseUp:ForceQuitButton() 
oBrowseDown:Activate() 

// Relacionamento entre os Paineis 
oRelac:= FWBrwRelation():New() 
if nOpt == 1
	oRelac:AddRelation( oBrowseUp , oBrowseDown , { { 'cArqGrd2->FILIAL', 'cArqGrd1->FILIAL'}, {'cArqGrd2->COD','cArqGrd1->COD'} }) 
endif
if nOpt == 2
	oRelac:AddRelation( oBrowseUp , oBrowseDown , { { 'cArqGrd2->FILIAL', 'cArqGrd1->FILIAL'}, {'cArqGrd2->CODGRD','cArqGrd1->CODGRD'} }) 
endif
oRelac:Activate() 

Activate MsDialog oDlgPrinc Center 

cArqGrd1->(DbCloseArea())
cArqGrd2->(DbCloseArea())

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
MenuDef - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

// Necessario declarar a Function

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}MontaColunas
Monta colunas a serem exibidas em tela - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	
	Local aColumn
	Local bData 	 := {||}
	
	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") 
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

//-------------------------------------------------------------------
/*/{Protheus.doc}xDescPro
Busca descrição do produto - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xDescPro(cCod)

Local aArea   := GetArea() 
Local cDESCR  := ""

DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cCod)
	cDESCR  := Alltrim(SB1->B1_DESC) + " " + Alltrim(SB1->B1_XMARCA)
EndIf

RestArea( aArea )

Return cDESCR 

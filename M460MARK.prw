#include "protheus.ch" 
#include "topconn.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460MARK  บAutor  ณ FONTANELLI	     บ Data ณ  14/05/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada utilizado para validar itens selecionados  บฑฑ
ฑฑบ          ณna tela Documento de Saida para emissao de NF.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M460MARK()

Local aArea    := GetArea()

Local cMarca 	:= PARAMIXB[1]
Local lInverte  := PARAMIXB[2]  
Local cSerie	:= ParamIXB[3]

Local lRet:= .T.

Pergunte("MT461A",.F.)               
 
cQuery := " SELECT DISTINCT C9_PEDIDO "
cQuery += "   FROM "+RetSqlName("SC9")+" "
cQuery += "  WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cQuery += "    AND C9_PEDIDO  BETWEEN '"+mv_par05+"' and '"+mv_par06+"' "
cQuery += "    AND C9_CLIENTE BETWEEN '"+mv_par07+"' and '"+mv_par08+"' "
cQuery += "    AND C9_LOJA    BETWEEN '"+mv_par09+"' and '"+mv_par10+"' "
cQuery += "    AND C9_DATALIB BETWEEN '"+DtoS(mv_par11)+"' and '"+DtoS(mv_par12)+"' "
cQuery += "    AND "+IIf(lInverte,"C9_OK <> '","C9_OK = '")+cMarca+"' "
cQuery += "    AND C9_NFISCAL = ' ' "
cQuery += "    AND C9_BLEST = ' ' "
cQuery += "    AND C9_BLCRED = ' ' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QrySC9",.T.,.T.)
dbSelectArea("QrySC9")
QrySC9->(dbGoTop())
While !QrySC9->(Eof()) 

	DbSelectArea("SC5")
	DbsetOrder(1) // C5_FILIAL+C5_NUM
	SC5->(DbGotop())
	if DbSeek(xFilial("SC5")+QrySC9->C9_PEDIDO)
		if SC5->C5_XCONF <> 'S'
			MsgBox("Pedido de Venda: " + SC5->C5_NUM + " nใo estแ apto a faturar, verificar conferencia...", "Ponto de Entrada: M460MARK", "STOP")
			lRet := .F.
		endif
	endif
	QrySC9->(DbSkip())
EndDo
QrySC9->(dbCloseArea())

RestArea(aArea)

Return(lRet)



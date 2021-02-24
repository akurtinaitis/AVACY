#include 'protheus.ch'
#include "rwmake.ch"

User Function LJ701key()

Local aArea    := GetArea()
Local lIsCaixa := LJProFile(3) //Verifica se no perfil de caixa est� configurado como "Usu�rio � caixa"
local lRet     := .t.

If (lIsCaixa) // Permite continuar se usu�rio � caixa
	if Altera
		if SL1->L1_XCONF <> 'S'
			MsgBox("Or�amento: " + SL1->L1_NUM + " n�o est� apto a faturar, verificar conferencia...", "Ponto de Entrada: LJ701kEY", "STOP")
			lRet := .F.
		endif
	endif
endif	

RestArea(aArea)
 
Return(lRet)

#include 'protheus.ch'
#include "rwmake.ch"

User Function LJ701key()

Local aArea    := GetArea()
Local lIsCaixa := LJProFile(3) //Verifica se no perfil de caixa está configurado como "Usuário é caixa"
local lRet     := .t.

If (lIsCaixa) // Permite continuar se usuário é caixa
	if Altera
		if SL1->L1_XCONF <> 'S'
			MsgBox("Orçamento: " + SL1->L1_NUM + " não está apto a faturar, verificar conferencia...", "Ponto de Entrada: LJ701kEY", "STOP")
			lRet := .F.
		endif
	endif
endif	

RestArea(aArea)
 
Return(lRet)

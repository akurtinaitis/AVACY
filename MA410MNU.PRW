#Include "Protheus.ch"

User Function MA410MNU() 
 
    aadd(aRotina,{'PickList AVACY','U_AVCR01("FAT")' , 0 , 3,0,NIL}) 
    aadd(aRotina,{'Conferencia Automatica AVACY','U_AvcConf("FAT")' , 0 , 3,0,NIL}) 
    aadd(aRotina,{'Consulta Estoque AVACY','U_Avacy04()' , 0 , 3,0,NIL}) 

Return (aRotina)
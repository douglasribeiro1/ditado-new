' Abre o Ditado sem mostrar a janela preta do .bat (use este no atalho).
Set sh = CreateObject("WScript.Shell")
dir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
sh.Run """" & dir & "\Abrir-Ditado.bat""", 0, False

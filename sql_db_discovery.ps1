#################################################################################################
#
# Автообнаружение всех баз данных во всех локальных экземплярах для Zabbix
#
#################################################################################################

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$colstrInstances = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
$excludeDB = "master", "model", "msdb", "perflog", "tempdb", "ReportServer", "ReportServerTempDB"
$strContent = ""
write-host "{"
write-host " `"data`":["
write-host
foreach ($strInstance in $colstrInstances)
{
   If ($strInstance -eq 'MSSQLSERVER')
   {
       $strInstance = '.'
   }
   else
   {
       $strInstance = '.\' + $strInstance
   }
   try
   {
       $objInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') ($strInstance)
       $colobjDB=$objInstance.Databases
       foreach ($objDB in $colobjDB | where-object {!($excludeDB -contains $_.name)})
       {
           $strContent +=((" { `"{#INSTANCE}`":`"") + $strInstance.replace("\", "\\") + ("`", `"{#DATABASE}`":`"") + $objDB.name + "`", `"{#INSTANCE1}`":`"" + $strInstance.replace("\", "//") + ("`"},") + [char]10)
       }
   }
   catch
   {
           #  Не возможно подключиться к серверу баз данных, пропускаем ошибку
   }
}
write-host $strContent.Substring(0,($strContent.Length-2))
write-host
write-host " ]"
write-host "}"
write-host

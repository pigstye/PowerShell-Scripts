<#
	.Synopsis
		Converts XML Tasks from Windows to PSObject
	.Description
		Given a filename it parses the XML task and converts it to a PSObject Suitable for placing in CSV
	.Parameter FileName
		Full path to the xml task
	.NOTES
		Author: Tom Willett
		Date: 7/1/2021
#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$filename)


function get-properties {
	<#
		.Synopsis
			Converts the Properties from an XML Task to PSObject
		.Description
			Given a property name it parses the XML task and converts it to a PSObject Suitable for placing in CSV
		.Parameter PropName
			Property Name
		.NOTES
			Author: Tom Willett
			Date: 7/1/2021
	#>
	Param([Parameter(Mandatory=$True)][string]$propname)
	$node = $task.task.$propname
	$properties = ($node | gm -MemberType property).name
	$info = ""
	foreach($prop in $properties) {
		if ($node.$prop.gettype().name -eq "String") {
			if ($info -ne "") { $info += "`r`n" }
			$info += $prop + " : " + $node.$prop
		} else {
			$properties1 = ($node.$prop | gm -MemberType property).name
			foreach($prop1 in $properties1) {
				if ($node.$prop.$prop1.gettype().name -eq "String") {
					if ($info -ne "") { $info += "`r`n" }
					$info += $prop + '-' + $prop1 + " : " + $node.$prop.$prop1
				} else {
					$properties2 = ($node.$prop.$prop1 | gm -MemberType property).name
					foreach($prop2 in $properties2) {
						if ($info -ne "") { $info += "`r`n" }
						$info += $prop + '-' + $prop1 + "-" + $prop2 + " : " + $node.$prop.$prop1.$prop2
					}
				}
			}
		}
	}
	$info
}


$fl = dir $filename

[xml]$task = gc $fl.fullname
$tmp = "" | select CreationDate,ModifiedDate,FileName,RegistrationInfo,Triggers,Settings,Actions,Principals
$tmp.CreationDate = $fl.creationtime
$tmp.ModifiedDate = $fl.lastwritetime
$tmp.FileName = $fl.fullname
$tmp.registrationinfo = get-properties('RegistrationInfo')
$tmp.triggers = get-properties('Triggers')
$tmp.settings = get-properties('Settings')
$tmp.actions = get-properties('Actions')
$tmp.Principals = get-properties('Principals')
$tmp
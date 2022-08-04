function Convert-IIStoCSV {
<#
	.Synopsis
		Convert IIS logs to CSV
	.Description
		Reads the header information from an IIS log and uses that to convert the log to CSV
	.Parameter logfile
		Log to Process
	.Example
		PS> convert-IIStoCSV iislog.txt | export-csv -notype iislog.cav
	.Example
		PS> dir *.log | convert-IIStoCSV | export-csv -notype iislogs.csv
	.NOTES
		Author: Tom Willett
		Date: 9/4/2021
#>
	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$Logfile)
	process {
		$f = dir $logfile
		((sls '#Fields:' $f.fullname).line).Substring(9) > tmp.csv
		sls -notmatch '^#' $f.fullname | %{$_.line} >> tmp.csv
		import-csv tmp.csv -delim ' ' | export-csv -notype -append ($f.basename + '.csv')
		rm tmp.csv
	}
}

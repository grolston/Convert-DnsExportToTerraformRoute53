function New-Route53Terraform {
    Param(
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ResourceName,

        # DNS value (e.g www)
        [string]
        $RecordName,
        # type of record (CNAME, A, etc)
        [string]
        $RecordType,
        # Record Value
        [string]
        $RecordValue,
        # Name of the Zone
        [string]
        $ZoneResourceName,
        # TTL given
        [string]
        $TTL


    )
    $text =  'resource "aws_route53_record" "' + $ResourceName + '" {' + "`n"
    $text +=  '  zone_id = "${aws_route53_zone.' + $ZoneResourceName + '.zone_id}"' + "`n"
    $text +=  '  name    = "' + $RecordName + '"' + "`n"
    $text +=  '  type    = "' + $RecordType + '"' + "`n"
    $text +=  '  ttl     = "'+ $TTL +'"' + "`n"
    $text +=  '  records = ["' + $RecordValue + '"]' + "`n"
    $text +=  '}' + "`n"
    return $text
}

# .Synopsis
#   Converts a DNS Export file to Terraform Route 53 file
# .DESCRIPTION
#   Takes a file that was exported from DNS provider and converts
#   it to a terraform file to be used with AWS Route 53 to create
#   all necessary records
function Convert-DnsExportToTerraformRoute53 {
Param(
        # Input File path of Exported DNS
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$InputFile,
        # Output File path of Exported DNS
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$OutputFile,
        # Output File path
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]$ZoneName,
        # Delimiter for input file
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [ValidateSet("space","tab")]
        [string]$Delimiter = "space"
    )
    if(test-path -Path $InputFile -ErrorAction SilentlyContinue){
        $DnsFile = Get-Content $InputFile
    }
    else {
        write-error -Message "File $InputFile does not exist" -ErrorAction Stop
    }

    $CNAMEs = ""
    $As = ""
    $MXs = ""
    $TXTs = ""
    $NSs = ""

    foreach ($line in $DnsFile){
        if($line -NOTLIKE ";*"){
            switch ($Delimiter) {
                'space' {$ParsedLine = $Line.Split(" ")}
                'tab' {$ParsedLine = $Line.Split("`t")}
            default {$ParsedLine = $Line.Split(" ")}
            }

            $RecordName = $ParsedLine[0]
            $ResourceName = $ParsedLine[0].Replace(".", "-")
            $TTL = $ParsedLine[1]
            $RecordType = $ParsedLine[3]
            $RecordValue= $ParsedLine[4]

            $TerraformString = New-Route53Terraform -ZoneResourceName $ZoneName -RecordName $RecordName -RecordType $RecordType -RecordValue $RecordValue -ResourceName $ResourceName -TTL $TTL
            switch ($RecordType) {
                'MX' {$MXs += "`n" + $TerraformString }
                'CNAME' {$CNAMEs += "`n" + $TerraformString }
                'A' {$As += "`n" + $TerraformString }
                'TXT' {$TXTs += "`n" + $TerraformString }
                'NS' { $NSs += "`n" + $TerraformString }
            }
            $TFResources += $TerraformString
        }
    }
    $TFResources| Out-File -FilePath $OutputFile

}#end Convert-DnsExportToTerraformRoute53
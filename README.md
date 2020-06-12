# Convert-DnsExportToTerraformRoute53

A quick PowerShell advanced function that will take a BIND file or DNS export file and do a quick conversion to terraform resource for AWS Route 53.

## Get Started

If you don't want to clone this repo and take the time to find file, set all security details, etc, simply run the following command to bring the Convert-DnsExportToTerraformRoute53 into your session for immediate use.

```ps
iex $(iwr https://raw.githubusercontent.com/grolston/Convert-DnsExportToTerraformRoute53/master/Convert-DnsExportToTerraformRoute53.ps1 -UseBasicParsing).Content
```

## Usage

Example of how to use a BIND file that uses a tab delimiter.

```ps
Convert-DnsExportToTerraformRoute53 -InputFile C:\Users\grols\git\example.com.txt -OutputFile C:\Users\grols\git\example.tf -ZoneName 'example.com' -Delimiter tab
```

Example of how to use a DNS export file that uses a space delimiter.

```ps
Convert-DnsExportToTerraformRoute53 -InputFile C:\Users\grols\git\example.com.txt -OutputFile C:\Users\grols\git\example.tf -ZoneName 'example.com' -Delimiter space
```

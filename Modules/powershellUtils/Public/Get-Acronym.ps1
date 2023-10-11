<#
.Synopsis
    Given an acronym, queries various web sources for definitions of the acronym.
.DESCRIPTION
    This function consumes an acronym and results various definitions of the acronym from various web sources. 
.EXAMPLE
    PS> Get-Acronym G2G

    Acronym Definition                                                     AdditionalInformation Source
    ------- ----------                                                     --------------------- ------
    G2G     Government To Government                                                             acronyms.silmaril.ie
    G2G     Government to Government                                                             acronymfinder.com
    G2G     Get Together                                                                         acronymfinder.com
    G2G     Good to Go                                                                           acronymfinder.com
    G2G     Got To Go                                                                            acronymfinder.com
    G2G     Good to Great (Jim Collins' theory about successful companies)                       acronymfinder.com
    G2G     Glory to God (also seen as GTG)                                                      acronymfinder.com
    G2G     Girl to Girl                                                                         acronymfinder.com
    G2G     Green to Gold (US Army commissioning program)                                        acronymfinder.com
    G2G     Go to Girl                                                                           acronymfinder.com
    G2G     Go to Gun (Antigo, WI)                                                               acronymfinder.com
    G2G     Gay to Gay                                                                           acronymfinder.com
    G2G     Guy to Girl                                                                          acronymfinder.com
    G2G     Growing to Greatness (various organizations)                                         acronymfinder.com
    G2G     Gateway to Growth (UK)                                                               acronymfinder.com
    G2G     Generation to Generation                                                             acronymfinder.com

.EXAMPLE
    PS> "HTML","WWW" | Get-Acronym -Source acronyms.silmaril.ie

    Acronym Definition                AdditionalInformation                                                               Source
    ------- ----------                ---------------------                                                               ------
    HTML    HyperText Markup Language SGML-based markup language used for information on the Web, being superseded by XML acronyms.silmaril.ie
    WWW     World Weather Watch                                                                                           acronyms.silmaril.ie
    WWW     World Wide Wait           well, that's what it means in TODAY'S world...                                      acronyms.silmaril.ie
    WWW     World Wide Web                                                                                                acronyms.silmaril.ie

    This example demonstrates the use of pipeline input, as well as specifying a source to search from.
#>
function Get-Acronym {
    [CmdletBinding()]
    param(
        #Specifies an acronym to get definitions for.
        [Parameter(
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Acronym = "HTML",

        #Specifes a web source to search. 
        #Web sources include: 'acronyms.silmaril.ie' and 'acronymfinder.com'
        #If no source is specified, all sources are searched.
        [ValidateSet(
            'All',
            'acronyms.silmaril.ie',
            'acronymfinder.com'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Source = 'All'
    )

    begin {

    }

    process {
        #Build all of the queries and their sources in a hashtable
        $queries = @{
            'acronyms.silmaril.ie' = "http://acronyms.silmaril.ie/cgi-bin/xaa?$Acronym"
            'acronymfinder.com'    = "https://www.acronymfinder.com/$Acronym.html"
        }
        
        #Filter out unspecified sources
        if ($Source -ne 'All') {
           $queries = $queries.GetEnumerator() | Where-Object Name -eq $Source
        }

        
        #Build a new hashtable containing the source and the result of the Invoke-WebRequest call
        $queryResult = @{}

        if ($Source -eq "All") {
            foreach ($query in $queries.GetEnumerator()) {
                try {
                    $queryResult += @{ $query.Name = $(Invoke-WebRequest -Uri $query.Value -ErrorAction Stop) }
                }
                catch {
                    throw
                }
            }
        }
        else {
            try {
                $queryResult += @{ $queries.Name = $(Invoke-WebRequest -Uri $queries.Value -ErrorAction Stop) }
            }
            catch {
                throw
            }
        }

        #Parse the Invoke-WebRequest results
        $finalResults = @()
        foreach ($result in $queryResult.GetEnumerator()) {
            switch ($result.Name) {
                
                'acronyms.silmaril.ie' {
                    $xmlContent = [xml]$result.Value.Content
                    
                    #Only get back records where the expan is type String, 
                    #because a record with a non-string is probably not what we're looking for. 
                    $entries = $xmlContent.acronym.found.acro | Where-Object expan -Is [String]

                    $finalResults += $entries | ForEach-Object { 
                        [pscustomobject] [ordered] @{
                            Acronym               = $Acronym
                            Definition            = $_.expan
                            AdditionalInformation = $_.comment
                            Source                = $result.Name
                        }
                    }
                }

                'acronymfinder.com' {
                    #TODO:
                    # Move parentheses text to AdditionalInformation property.


                    #Some acronyms, like NASA, are referenced as examples of acronyms you can search for on acronymfinder.com. 
                    #We want to remove extraneous results when an example acronym is searched.
                    $entries = $result.Value | 
                        Select-Object -ExpandProperty Links | 
                            Where-Object InnerHTML -eq $Acronym | 
                                Where-Object outerHTML -notmatch "example results for"

                    $finalResults += $entries | ForEach-Object {
                        [pscustomobject] [ordered] @{
                            Acronym               = $Acronym
                            Definition            = $($_.Title -replace "$Acronym - ",'')
                            AdditionalInformation = ''
                            Source                = $result.Name
                        }
                    }
                }
            }
        }

        Write-Output $finalResults
    }

    end {

    }
}
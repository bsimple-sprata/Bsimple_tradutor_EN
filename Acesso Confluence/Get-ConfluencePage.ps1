<#
.SYNOPSIS
    Lê o conteúdo de uma página do Confluence via API REST usando um API token.

.DESCRIPTION
    Usa Invoke-RestMethod com Basic Auth (email + API token) contra a API v2 do Confluence Cloud.
    Devolve o corpo da página em "storage format" (HTML/XML) e opcionalmente converte para texto simples.

.PARAMETER BaseUrl
    URL base do Confluence, ex: https://tuaempresa.atlassian.net

.PARAMETER Email
    Email da conta associada ao API token.

.PARAMETER ApiToken
    Token gerado em https://id.atlassian.com/manage-profile/security/api-tokens

.PARAMETER PageId
    ID numérico da página do Confluence.

.EXAMPLE
    .\Get-ConfluencePage.ps1 -BaseUrl "https://tuaempresa.atlassian.net" -Email "eu@empresa.com" -ApiToken $env:CONFLUENCE_API_TOKEN -PageId 123456
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$BaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$Email,

    [Parameter(Mandatory = $true)]
    [string]$ApiToken,

    [Parameter(Mandatory = $true)]
    [string]$PageId,

    [switch]$AsPlainText
)

# Monta o cabeçalho de autenticação Basic (email:token em Base64)
$pair = "$Email`:$ApiToken"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)

$headers = @{
    Authorization = "Basic $base64"
    Accept        = "application/json"
}

# API v2 (Confluence Cloud) - devolve o corpo em storage format
$uri = "$BaseUrl/wiki/api/v2/pages/$PageId`?body-format=storage"

try {
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
}
catch {
    Write-Error "Falha ao obter a página: $($_.Exception.Message)"
    return
}

$storageHtml = $response.body.storage.value

if ($AsPlainText) {
    # Conversão simples de HTML/storage format para texto simples
    Add-Type -AssemblyName System.Web
    $noTags = [System.Text.RegularExpressions.Regex]::Replace($storageHtml, "<[^>]+>", " ")
    $plain = [System.Web.HttpUtility]::HtmlDecode($noTags)
    $plain = ($plain -replace '\s+', ' ').Trim()
    Write-Output $plain
}
else {
    Write-Output $storageHtml
}

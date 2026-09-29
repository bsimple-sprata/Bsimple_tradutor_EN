<#
.SYNOPSIS
    Script único para ler, atualizar e criar Work Items no Azure DevOps Server (on-premise),
    fundindo as funcionalidades de Get-WorkItem.ps1 e Update-WorkItem.ps1.

.DESCRIPTION
    Os três modos (Get, Update, Create) autenticam-se da mesma forma: header
    "Authorization: Basic" com um PAT (Personal Access Token) lido da variável de
    ambiente ADO_PAT. Nenhum modo usa credenciais integradas do Windows.

    Modo GET: lê (consulta) um work item existente via API REST. Devolve o work item
    completo (todos os campos e relações) em JSON.

    Modo UPDATE: edita o campo "Title" e/ou "Description" de um work item existente.

    Modo CREATE: cria um novo work item (PBI/Task/etc.), preenchendo os campos
    obrigatórios (System.Title, System.Description, System.AreaPath, System.IterationPath,
    Custom.Categoria).

.PARAMETER Action
    Modo de funcionamento: "Get", "Update" ou "Create".

.PARAMETER WorkItemId
    ID do work item a consultar (modo Get) ou a editar (modo Update).

.PARAMETER NewTitle
    Modo Update: novo valor para o campo Title (opcional; tem de ser indicado -NewTitle e/ou -NewDescription).
    Modo Create: título do novo work item (obrigatório).

.PARAMETER NewDescription
    Modo Update: texto (simples, sem HTML) a aplicar ao campo Description.
    Se a descrição atual estiver vazia, este texto é definido como descrição.
    Se já existir descrição, este texto é acrescentado no fim da descrição existente.
    Modo Create: descrição do novo work item (opcional).

.PARAMETER Type
    Tipo do work item a criar (ex: "Product Backlog Item", "Task", "Bug"). Obrigatório no modo Create.

.PARAMETER ParentId
    ID do work item pai, para ligar o novo item criado como filho (opcional, só no modo Create).

.EXAMPLE
    .\Manage-WorkItem.ps1 -Action Get -WorkItemId 165112

.EXAMPLE
    .\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewTitle "Novo título do item"

.EXAMPLE
    .\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewTitle "Novo título" -NewDescription "Nota adicional sobre o item."

.EXAMPLE
    .\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewDescription "Só alterar a descrição, sem mexer no título."

.EXAMPLE
    .\Manage-WorkItem.ps1 -Action Create -Type "Task" -NewTitle "Nova tarefa" -NewDescription "Descrição da tarefa" -ParentId 1234
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Get', 'Update', 'Create')]
    [string]$Action,

    [Parameter(Mandatory = $false)]
    [int]$WorkItemId,

    [Parameter(Mandatory = $false)]
    [string]$NewTitle,

    [Parameter(Mandatory = $false)]
    [string]$NewDescription,

    [Parameter(Mandatory = $false)]
    [string]$Type,

    [Parameter(Mandatory = $false)]
    [int]$ParentId = 0
)

# --- Configuração fixa do ambiente ---
$OrgUrl   = "https://cleopatra/BSimpleCollection"
$Project  = "bunity"
$AreaPath = "bunity\Team8 - Equipa D"

# --- Variáveis e campos obrigatórios para a criação de novos work items ---
# Campos obrigatórios exigidos pelo ADO ao criar um PBI/Task neste projeto:
#   System.Title, System.Description, System.AreaPath, System.IterationPath, Custom.Categoria
$IterationPath  = "Bunity\2026\Sprint 285"   # alterar consoante o sprint atual
$CategoriaField = "PatientCare"              # valor do campo obrigatório Custom.Categoria

# --- PAT lido a partir de variável de ambiente (nunca hardcoded no script) ---
# Usado por todos os modos (Get, Update, Create).
$PAT = $env:ADO_PAT
if ([string]::IsNullOrWhiteSpace($PAT)) {
    Write-Error "Variável de ambiente ADO_PAT não definida. Configura-a antes de correr este script (ver README.md)."
    exit 1
}
$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$env:USERNAME`:$PAT"))
$Headers = @{ Authorization = "Basic $Base64Auth" }

# ============================================================
# MODO GET: autenticação via PAT (header Authorization: Basic)
# ============================================================
function Get-WorkItemDetails {
    param(
        [int]$Id,
        [hashtable]$Headers
    )

    $uri = "$OrgUrl/$Project/_apis/wit/workitems/$($Id)?api-version=6.0&`$expand=all"

    try {
        $item = Invoke-RestMethod -Uri $uri -Method Get -Headers $Headers
        $item | ConvertTo-Json -Depth 10
    }
    catch {
        Write-Error "Erro ao ler o work item: $($_.Exception.Message)"
        if ($_.ErrorDetails.Message) {
            Write-Error $_.ErrorDetails.Message
        }
        exit 1
    }
}

# ============================================================
# FUNÇÃO: Criar um novo work item (modo Create)
# ============================================================
function New-WorkItem {
    param(
        [string]$Type,
        [string]$Title,
        [string]$Description,
        [int]$ParentId = 0,
        [hashtable]$Headers
    )

    # --- Escaping para JSON ---
    $TitleEscaped         = $Title -replace '"', '\"'
    $DescEscaped          = $Description -replace '"', '\"' -replace "`n", '\n'
    $AreaPathEscaped      = $AreaPath -replace '\\', '\\'
    $IterationPathEscaped = $IterationPath -replace '\\', '\\'

    # --- Relação com o pai em JSON ---
    $ParentRelation = ""
    if ($ParentId -gt 0) {
        $ParentRelation = ",`n  { `"op`": `"add`", `"path`": `"/relations/-`", `"value`": { `"rel`": `"System.LinkTypes.Hierarchy-Reverse`", `"url`": `"$OrgUrl/$Project/_apis/wit/workItems/$ParentId`", `"attributes`": { `"comment`": `"Child task`" } } }"
    }

    # --- Campos obrigatórios: Title, Description, AreaPath, IterationPath, Custom.Categoria ---
    $BodyJson = @"
[
  { "op": "add", "path": "/fields/System.Title",         "value": "$TitleEscaped" },
  { "op": "add", "path": "/fields/System.Description",   "value": "$DescEscaped" },
  { "op": "add", "path": "/fields/System.AreaPath",      "value": "$AreaPathEscaped" },
  { "op": "add", "path": "/fields/System.IterationPath", "value": "$IterationPathEscaped" },
  { "op": "add", "path": "/fields/Custom.Categoria",     "value": "$CategoriaField" }$ParentRelation
]
"@

    $TypeEncoded = [Uri]::EscapeDataString($Type)
    $CreateUri   = "$OrgUrl/$Project/_apis/wit/workitems/`$$TypeEncoded`?api-version=6.0"

    $Response = Invoke-RestMethod -Uri $CreateUri -Method Post -Headers $Headers `
                                  -ContentType "application/json-patch+json" `
                                  -Body ([System.Text.Encoding]::UTF8.GetBytes($BodyJson))
    return $Response
}

# ============================================================
# LÓGICA PRINCIPAL: dispatch consoante -Action
# ============================================================

switch ($Action) {

    'Get' {
        if (-not $PSBoundParameters.ContainsKey('WorkItemId')) {
            Write-Error "No modo -Action Get tens de indicar -WorkItemId."
            exit 1
        }
        Get-WorkItemDetails -Id $WorkItemId -Headers $Headers
        exit 0
    }

    'Create' {
        if (-not $PSBoundParameters.ContainsKey('Type')) {
            Write-Error "No modo -Action Create tens de indicar -Type (ex: 'Product Backlog Item', 'Task')."
            exit 1
        }
        if (-not $PSBoundParameters.ContainsKey('NewTitle')) {
            Write-Error "No modo -Action Create tens de indicar -NewTitle."
            exit 1
        }

        try {
            $created = New-WorkItem -Type $Type -Title $NewTitle -Description $NewDescription -ParentId $ParentId -Headers $Headers
            Write-Host "Work item criado com sucesso. Id: $($created.id)"
            Write-Host "Título: $($created.fields.'System.Title')"
            if ($ParentId -gt 0) {
                Write-Host "Ligado como filho do work item $ParentId."
            }
        }
        catch {
            Write-Error "Erro ao criar o work item: $($_.Exception.Message)"
            if ($_.ErrorDetails.Message) {
                Write-Error $_.ErrorDetails.Message
            }
            exit 1
        }
        exit 0
    }

    'Update' {
        if (-not $PSBoundParameters.ContainsKey('WorkItemId')) {
            Write-Error "No modo -Action Update tens de indicar -WorkItemId."
            exit 1
        }
        if (-not $PSBoundParameters.ContainsKey('NewTitle') -and -not $PSBoundParameters.ContainsKey('NewDescription')) {
            Write-Error "No modo -Action Update tens de indicar pelo menos -NewTitle ou -NewDescription."
            exit 1
        }

        $uri = "$OrgUrl/$Project/_apis/wit/workitems/$($WorkItemId)?api-version=6.0"

        # --- Corpo do pedido (JSON Patch) ---
        $patchOps = @()

        if ($PSBoundParameters.ContainsKey('NewTitle')) {
            $patchOps += @{
                op    = "replace"
                path  = "/fields/System.Title"
                value = $NewTitle
            }
        }

        # --- Se foi pedida alteração à descrição, lê o valor atual e decide add/replace ---
        if ($PSBoundParameters.ContainsKey('NewDescription')) {
            try {
                $current = Invoke-RestMethod -Uri $uri -Method Get -Headers $Headers
            }
            catch {
                Write-Error "Erro ao ler o work item para obter a descrição atual: $($_.Exception.Message)"
                exit 1
            }

            $currentDescription = $current.fields.'System.Description'

            if ([string]::IsNullOrWhiteSpace($currentDescription)) {
                $patchOps += @{
                    op    = "add"
                    path  = "/fields/System.Description"
                    value = $NewDescription
                }
            }
            else {
                $patchOps += @{
                    op    = "replace"
                    path  = "/fields/System.Description"
                    value = "$currentDescription`n$NewDescription"
                }
            }
        }

        $body = ConvertTo-Json -InputObject $patchOps

        try {
            $response = Invoke-RestMethod -Uri $uri `
                -Method Patch `
                -Headers $Headers `
                -ContentType "application/json-patch+json" `
                -Body $body

            Write-Host "Work item $WorkItemId atualizado com sucesso."
            if ($PSBoundParameters.ContainsKey('NewTitle')) {
                Write-Host "Novo título: $($response.fields.'System.Title')"
            }
            if ($PSBoundParameters.ContainsKey('NewDescription')) {
                Write-Host "Nova descrição: $($response.fields.'System.Description')"
            }
        }
        catch {
            Write-Error "Erro ao atualizar o work item: $($_.Exception.Message)"
            if ($_.ErrorDetails.Message) {
                Write-Error $_.ErrorDetails.Message
            }
            exit 1
        }
        exit 0
    }
}

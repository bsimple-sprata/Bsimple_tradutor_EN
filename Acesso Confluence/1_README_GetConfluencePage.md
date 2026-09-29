## README Get-ConfluencePage.ps1

Script PowerShell para ler o conteúdo de uma página do Confluence Cloud através da API REST (v2), usando autenticação por API token.

## Descrição

O script:
1. Constrói um cabeçalho de autenticação **Basic Auth** (email + API token, codificado em Base64).
2. Faz um pedido `GET` à API v2 do Confluence Cloud (`/wiki/api/v2/pages/{PageId}`), pedindo o corpo da página em *storage format* (HTML/XML).
3. Devolve o conteúdo da página:
   - Em bruto (HTML/storage format), por omissão; ou
   - Convertido para texto simples, se for usado o parâmetro `-AsPlainText`.

## Pré-requisitos

- PowerShell 5.1+ (ou PowerShell 7+ multiplataforma).
- Uma conta Atlassian com acesso ao Confluence Cloud.
- Um **API Token** gerado em:
  https://id.atlassian.com/manage-profile/security/api-tokens

> ⚠️ **Nunca coloques o token diretamente no script.** Usa uma variável de ambiente ou introduz o valor de forma segura no momento da execução.

## Parâmetros

| Parâmetro     | Obrigatório | Descrição                                                                 |
|---------------|:-----------:|----------------------------------------------------------------------------|
| `-BaseUrl`    | Sim         | URL base do Confluence, ex: `https://tuaempresa.atlassian.net`             |
| `-Email`      | Sim         | Email da conta associada ao API token.                                    |
| `-ApiToken`   | Sim         | Token de API gerado na conta Atlassian.                                   |
| `-PageId`     | Sim         | ID numérico da página do Confluence.                                      |
| `-AsPlainText`| Não         | *Switch*. Se presente, converte o HTML para texto simples (remove tags).  |

## Como definir o token e o email em variável de ambiente

**PowerShell (sessão atual):**
```powershell
$env:CONFLUENCE_API_TOKEN = "o-teu-token-aqui"
```

**Windows (permanente, ao nível do utilizador):**
TOKEN
```powershell
[System.Environment]::SetEnvironmentVariable("CONFLUENCE_API_TOKEN", "o-teu-token-aqui", "User")
```
EMAIL
```powershell
[System.Environment]::SetEnvironmentVariable("CONFLUENCE_EMAIL", "email@b-simple.pt", "User")
```

## Exemplos de utilização

### 1. Obter o conteúdo em HTML (storage format)
```powershell
.\Get-ConfluencePage.ps1 `
    -BaseUrl "https://tuaempresa.atlassian.net" `
    -Email "eu@empresa.com" `
    -ApiToken $env:CONFLUENCE_API_TOKEN `
    -PageId 123456
```

### 2. Obter o conteúdo como texto simples
```powershell
.\Get-ConfluencePage.ps1 `
    -BaseUrl "https://tuaempresa.atlassian.net" `
    -Email "eu@empresa.com" `
    -ApiToken $env:CONFLUENCE_API_TOKEN `
    -PageId 123456 `
    -AsPlainText
```

### 3. Guardar o resultado num ficheiro
```powershell
.\Get-ConfluencePage.ps1 `
    -BaseUrl "https://tuaempresa.atlassian.net" `
    -Email "eu@empresa.com" `
    -ApiToken $env:CONFLUENCE_API_TOKEN `
    -PageId 123456 `
    -AsPlainText | Out-File -FilePath "pagina.txt" -Encoding utf8
```

## Tratamento de erros

Se o pedido falhar (ex: credenciais inválidas, página inexistente, falta de permissões), o script escreve um erro descritivo através de `Write-Error` e termina sem devolver conteúdo.

## Notas

- O script usa a **API v2** do Confluence Cloud; não é compatível com instalações *Server/Data Center* que utilizem apenas a API v1, salvo adaptação.
- A conversão para texto simples (`-AsPlainText`) é básica: remove tags HTML e descodifica entidades, mas não preserva formatação (tabelas, listas, etc.).

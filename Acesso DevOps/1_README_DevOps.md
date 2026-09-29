# Scripts de Work Items – Azure DevOps Server (on-premise)

Este repositório contém scripts PowerShell para consultar, atualizar e criar
Work Items num Azure DevOps Server (on-premise), na coleção `BSimpleCollection`,
projeto `bunity`.

## `Manage-WorkItem.ps1` (script recomendado)

Fusão de `Get-WorkItem.ps1` e `Update-WorkItem.ps1` num único script, sem perda
de funcionalidades. Suporta três modos através do parâmetro `-Action`:

- **`Get`**: lê (consulta) um work item existente. Equivalente a `Get-WorkItem.ps1`.
- **`Update`**: edita o `Title` e/ou `Description` de um work item existente.
  Equivalente ao modo predefinido de `Update-WorkItem.ps1`.
- **`Create`**: cria um novo work item (PBI/Task/etc.). Equivalente ao modo `-CreateNew`
  de `Update-WorkItem.ps1`.

- **Autenticação (todos os modos):** header `Authorization: Basic` com um PAT
  (Personal Access Token), lido a partir da variável de ambiente `ADO_PAT` (ver
  secção [Configurar a variável de ambiente `ADO_PAT`](#configurar-a-variável-de-ambiente-ado_pat)
  abaixo). Já **não** usa credenciais integradas do Windows em nenhum modo — inclui
  o antigo modo Get, que agora também autentica via PAT. Se `ADO_PAT` não estiver
  definida, o script termina com um erro.

**Parâmetros:**

| Parâmetro         | Modo(s)         | Obrigatório | Descrição |
|-------------------|-----------------|-------------|-----------|
| `-Action`         | todos           | Sim         | `Get`, `Update` ou `Create`. |
| `-WorkItemId`     | Get, Update     | Sim         | ID do work item a consultar/editar. |
| `-NewTitle`       | Update, Create  | Ver notas   | Update: novo título. Create: título do novo item (obrigatório). |
| `-NewDescription` | Update, Create  | Não         | Update: texto acrescentado à descrição. Create: descrição do novo item. |
| `-Type`           | Create          | Sim         | Tipo do work item (ex: `Product Backlog Item`, `Task`, `Bug`). |
| `-ParentId`       | Create          | Não         | ID do work item pai, para ligar o novo item criado como filho. |

No modo `Update` é obrigatório indicar pelo menos `-NewTitle` ou `-NewDescription`.

**Exemplos:**
```powershell
# Consultar um work item
.\Manage-WorkItem.ps1 -Action Get -WorkItemId 165112

# Atualizar apenas o título
.\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewTitle "Novo título do item"

# Atualizar título e adicionar nota à descrição
.\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewTitle "Novo título" -NewDescription "Nota adicional sobre o item."

# Atualizar apenas a descrição
.\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewDescription "Só alterar a descrição, sem mexer no título."

# Criar uma nova tarefa, filha de um work item existente
.\Manage-WorkItem.ps1 -Action Create -Type "Task" -NewTitle "Nova tarefa" -NewDescription "Descrição da tarefa" -ParentId 1234
```

## Ficheiros originais (mantidos por compatibilidade)

Os scripts `Get-WorkItem.ps1` e `Update-WorkItem.ps1` foram mantidos no repositório
para não quebrar automatismos/atalhos existentes que ainda os invoquem diretamente,
mas o uso recomendado a partir de agora é `Manage-WorkItem.ps1`.

### `Get-WorkItem.ps1`

Lê (consulta) um Work Item existente através da API REST do Azure DevOps.

- **Autenticação:** integrada do Windows (NTLM/Kerberos), via `-UseDefaultCredentials`.
  Não é necessário um Personal Access Token (PAT).
- **Parâmetro:**
  - `-WorkItemId` (obrigatório): ID do work item a consultar.
- **Saída:** o work item completo (todos os campos e relações, `$expand=all`) em formato JSON.

**Exemplo:**
```powershell
.\Get-WorkItem.ps1 -WorkItemId 165112
```

### `Update-WorkItem.ps1`

Atualiza um Work Item existente ou cria um novo, através da API REST do Azure DevOps.

- **Autenticação:** header `Authorization: Basic` com um PAT (Personal Access Token),
  em vez de credenciais integradas do Windows. O PAT já **não** está escrito no
  código: é lido a partir da variável de ambiente `ADO_PAT` (ver secção
  [Configurar a variável de ambiente `ADO_PAT`](#configurar-a-variável-de-ambiente-ado_pat) abaixo).
  Se a variável não estiver definida, o script termina com um erro.
- **Modos de funcionamento:**
  - **UPDATE (predefinido):** edita o campo `Title` e/ou `Description` de um work item existente.
    - Se a descrição atual estiver vazia, o novo texto é definido como descrição.
    - Se já existir descrição, o novo texto é acrescentado no fim da existente.
  - **CREATE (`-CreateNew`):** cria um novo work item (PBI/Task/etc.), preenchendo os campos
    obrigatórios do projeto: `System.Title`, `System.Description`, `System.AreaPath`,
    `System.IterationPath` e `Custom.Categoria`. Permite ainda ligar o novo item como
    filho de outro work item (`-ParentId`).

**Parâmetros principais:**

| Parâmetro         | Modo   | Obrigatório | Descrição |
|-------------------|--------|-------------|-----------|
| `-WorkItemId`     | UPDATE | Sim         | ID do work item a editar. |
| `-NewTitle`       | ambos  | Ver notas   | UPDATE: novo título. CREATE: título do novo item (obrigatório). |
| `-NewDescription` | ambos  | Não         | UPDATE: texto acrescentado à descrição. CREATE: descrição do novo item. |
| `-CreateNew`      | CREATE | —           | Ativa o modo de criação de um novo work item. |
| `-Type`           | CREATE | Sim         | Tipo do work item (ex: `Product Backlog Item`, `Task`, `Bug`). |
| `-ParentId`       | CREATE | Não         | ID do work item pai, para ligar o novo item criado como filho. |

No modo UPDATE é obrigatório indicar pelo menos `-NewTitle` ou `-NewDescription`.

**Exemplos:**
```powershell
# Atualizar apenas o título
.\Update-WorkItem.ps1 -WorkItemId 1234 -NewTitle "Novo título do item"

# Atualizar título e adicionar nota à descrição
.\Update-WorkItem.ps1 -WorkItemId 1234 -NewTitle "Novo título" -NewDescription "Nota adicional sobre o item."

# Atualizar apenas a descrição
.\Update-WorkItem.ps1 -WorkItemId 1234 -NewDescription "Só alterar a descrição, sem mexer no título."

# Criar uma nova tarefa, filha de um work item existente
.\Update-WorkItem.ps1 -CreateNew -Type "Task" -NewTitle "Nova tarefa" -NewDescription "Descrição da tarefa" -ParentId 1234
```

## Configuração fixa (todos os scripts)

- **Organização:** `https://cleopatra/BSimpleCollection`
- **Projeto:** `bunity`

`Manage-WorkItem.ps1` (e `Update-WorkItem.ps1`) definem adicionalmente `AreaPath`,
`IterationPath` (sprint atual) e `Custom.Categoria`, usados no modo `Create`/`-CreateNew`.

## Configurar a variável de ambiente `ADO_PAT`

Nenhum dos scripts tem o PAT escrito no código. Todos leem o PAT a partir da
variável de ambiente `ADO_PAT` no arranque. É necessário definir esta variável
antes de correr qualquer um dos scripts (incluindo o modo `Get` de
`Manage-WorkItem.ps1`, que anteriormente usava credenciais integradas do Windows).

### Passo 1 – Criar/obter o PAT no Azure DevOps

1. No Azure DevOps Server, ir a **User settings → Personal access tokens**.
2. Criar um novo token (ou reutilizar um existente) com permissões de leitura/escrita
   sobre **Work Items**.
3. Copiar o valor do token gerado (só é mostrado uma vez).

### Passo 2 – Definir a variável de ambiente `ADO_PAT`

**Opção A – Apenas para a sessão atual do PowerShell** (não persiste depois de fechar a consola):
```powershell
$env:ADO_PAT = "o-teu-token-aqui"
```

**Opção B – Persistente para o utilizador atual** (fica disponível em novas sessões/reinícios):
```powershell
[System.Environment]::SetEnvironmentVariable("ADO_PAT", "o-teu-token-aqui", "User")
```
Depois de definir desta forma, é preciso abrir uma **nova** janela do PowerShell (ou
reiniciar o terminal/IDE) para a variável ficar disponível.

**Opção C – Via interface gráfica do Windows:**
1. Abrir **Editar as variáveis de ambiente do sistema** (pesquisar no menu Iniciar).
2. Clicar em **Variáveis de Ambiente…**.
3. Em **Variáveis de utilizador**, clicar em **Novo…**.
4. Nome da variável: `ADO_PAT`. Valor da variável: o token copiado no Passo 1.
5. Confirmar com **OK** e reiniciar o terminal/IDE.

### Passo 3 – Verificar

```powershell
echo $env:ADO_PAT
```
Deve mostrar o token definido. Se aparecer vazio, a variável não está configurada
corretamente para a sessão atual.

### Passo 4 – Correr o script

```powershell
.\Manage-WorkItem.ps1 -Action Get -WorkItemId 1234
.\Manage-WorkItem.ps1 -Action Update -WorkItemId 1234 -NewTitle "Novo título do item"
```
Se `ADO_PAT` não estiver definida, o script termina com o erro:
`Variável de ambiente ADO_PAT não definida. Configura-a antes de correr este script (ver README.md).`



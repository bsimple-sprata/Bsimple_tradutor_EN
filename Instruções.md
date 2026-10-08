## 1) Criação ou atualização do ficheiro de instruções locais nos agentes de IA:
Utilizar uma das opções A,B ou C consoante a plataforma em utilização. Copiar e colar o ficheiro correspondente para as localizações indicadas OU se já existir, atualizar com um editor de texto com o conteúdo correspondente:

### A) Para Claude code:   
C:\Users\Ana\.claude\CLAUDE.md
ou 
C:\Utilizadores\Ana\ .claude\CLAUDE.md
### B) Para Codex:
C:\Users\Ana\.codex\AGENTS.md
ou
C:\Utilizadores\Ana\ .codex\AGENTS.md

### C) Para Copilot CLI:

C:\Users\Ana\.copilot\copilot-instructions.md
ou 
C:\Utilizadores\Ana\ .copilot\copilot-instructions.md


### D) Para Visual Studio com GitHub Copilot

1. Criar a pasta `.github` na raiz do repositório, caso ainda não exista.
2. Copiar `copilot-instructions.md` para:

+   `.github/copilot-instructions.md`

3. Abrir o Visual Studio com o repositório ou solução.
4. Activar o carregamento de instruções personalizadas nas opções:

 + `Tools > Options > GitHub > Copilot > Copilot Chat`

5. Activar a opção equivalente a:

  + `Enable custom instructions to be loaded from .github/copilot-instructions.md files`

6. Confirmar, numa resposta do Copilot, que `.github/copilot-instructions.md`
   aparece na lista de referências utilizadas.

O ficheiro da raiz `copilot-instructions.md` pode ser mantido como fonte original,
mas o ficheiro utilizado pelo Copilot no Visual Studio deve estar em
`.github/copilot-instructions.md`.

## 2) Criação de mecanismo de ligação ao Confluence:
Seguir as instruções do ficheiro README dentro da pasta "Acesso Confluence"
Se não for usado acesso via script Powershell adaptar de acordo.

## 3) Criação de mecanismo de ligação ao Azure DevOps:
Seguir as instruções do ficheiro README dentro da pasta "Acesso DevOps"
Se não for usado acesso via script Powershell adaptar de acordo.

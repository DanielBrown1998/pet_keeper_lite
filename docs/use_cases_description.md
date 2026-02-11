# Descrição dos Casos de Uso - PetKeeper Lite

> Documentação UML 2.0 - Especificação completa dos casos de uso

---

## Índice

1. [Autenticação](#1-autenticação)
2. [Família](#2-família)
3. [Pets](#3-pets)
4. [Tarefas/Vacinas](#4-tarefasvacinas)
5. [Notificações](#5-notificações)

---

## 1. Autenticação

### UC-001: Fazer Login com Email/Senha

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-001 |
| **Nome** | Fazer Login com Email/Senha |
| **Ator Principal** | Usuário (não autenticado) |
| **Atores Secundários** | Firebase Auth |
| **Pré-condições** | - Usuário possui conta cadastrada<br>- App está conectado à internet |
| **Pós-condições** | - Usuário autenticado<br>- Token FCM configurado<br>- Redirecionado para tela principal ou onboarding família |

**Fluxo Principal:**
1. Usuário acessa a tela de login
2. Usuário informa email e senha
3. Sistema valida formato do email
4. Sistema envia credenciais ao Firebase Auth
5. Firebase Auth valida credenciais
6. Sistema obtém dados do usuário do Firestore
7. Sistema configura token FCM
8. Sistema verifica se usuário possui `familyCode`
9. Se possui família: redireciona para lista de pets
10. Se não possui família: redireciona para onboarding família

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 3a | Email inválido | Sistema exibe "Email inválido" |
| 5a | Senha incorreta | Sistema exibe "Senha incorreta" |
| 5b | Usuário não existe | Sistema exibe "Usuário não encontrado" |

**Fluxos de Exceção:**

| ID | Condição | Ação |
|----|----------|------|
| E1 | Sem conexão | Sistema exibe "Sem conexão com a internet" |
| E2 | Timeout | Sistema exibe "Tempo esgotado. Tente novamente" |

**Regras de Negócio:**
- RN01: Email deve ter formato válido (regex)
- RN02: Senha deve ter no mínimo 6 caracteres
- RN03: Token FCM deve ser atualizado a cada login

---

### UC-002: Fazer Login com Google

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-002 |
| **Nome** | Fazer Login com Google |
| **Ator Principal** | Usuário (não autenticado) |
| **Atores Secundários** | Firebase Auth, Google Sign-In |
| **Pré-condições** | - Dispositivo possui conta Google configurada<br>- App está conectado à internet |
| **Pós-condições** | - Usuário autenticado<br>- Documento criado no Firestore (se primeiro acesso)<br>- Token FCM configurado |

**Fluxo Principal:**
1. Usuário toca no botão "Entrar com Google"
2. Sistema abre popup de seleção de conta Google
3. Usuário seleciona conta
4. Google autentica e retorna credenciais
5. Sistema envia credenciais ao Firebase Auth
6. Sistema verifica se documento do usuário existe no Firestore
7. Se não existe: cria documento com dados do Google
8. Sistema configura token FCM
9. Sistema verifica `familyCode` e redireciona

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 3a | Usuário cancela seleção | Retorna à tela de login |
| 6a | Documento já existe | Atualiza `displayName` se necessário |

**Fluxos de Exceção:**

| ID | Condição | Ação |
|----|----------|------|
| E1 | Google Sign-In falhou | Sistema exibe "Falha na autenticação Google" |
| E2 | Firebase rejeitou credencial | Sistema exibe "Erro ao autenticar" |

**Regras de Negócio:**
- RN01: `displayName` e `email` são obtidos do perfil Google
- RN02: Se usuário já existe, não sobrescrever `familyCode`

---

### UC-003: Criar Conta

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-003 |
| **Nome** | Criar Conta |
| **Ator Principal** | Usuário (não autenticado) |
| **Atores Secundários** | Firebase Auth, Firestore |
| **Pré-condições** | - Email não cadastrado anteriormente<br>- App conectado à internet |
| **Pós-condições** | - Conta criada no Firebase Auth<br>- Documento criado no Firestore<br>- Usuário autenticado |

**Fluxo Principal:**
1. Usuário acessa tela de cadastro
2. Usuário informa nome, email e senha
3. Sistema valida campos
4. Sistema cria conta no Firebase Auth
5. Sistema cria documento no Firestore com dados iniciais
6. Sistema configura token FCM
7. Sistema redireciona para onboarding família

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 3a | Email já cadastrado | Sistema exibe "Email já está em uso" |
| 3b | Senha fraca | Sistema exibe "Senha deve ter no mínimo 6 caracteres" |

**Regras de Negócio:**
- RN01: Nome deve ter no mínimo 2 caracteres
- RN02: Email deve ser único no sistema
- RN03: Senha deve ter no mínimo 6 caracteres
- RN04: `familyCode` inicial é null
- RN05: `fcmTokens` inicial é array vazio

---

### UC-004: Fazer Logout

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-004 |
| **Nome** | Fazer Logout |
| **Ator Principal** | Membro da Família (autenticado) |
| **Atores Secundários** | Firebase Auth |
| **Pré-condições** | - Usuário está autenticado |
| **Pós-condições** | - Sessão encerrada<br>- Redirecionado para tela de login |

**Fluxo Principal:**
1. Usuário acessa menu/configurações
2. Usuário toca em "Sair"
3. Sistema solicita confirmação
4. Usuário confirma
5. Sistema encerra sessão no Firebase Auth
6. Sistema limpa dados locais
7. Sistema redireciona para tela de login

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 4a | Usuário cancela | Retorna à tela anterior |

---

### UC-005: Verificar Autenticação

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-005 |
| **Nome** | Verificar Autenticação |
| **Ator Principal** | Sistema (automático) |
| **Atores Secundários** | Firebase Auth |
| **Pré-condições** | - App foi iniciado |
| **Pós-condições** | - Estado de autenticação determinado<br>- Redirecionamento adequado |

**Fluxo Principal:**
1. App é iniciado
2. Sistema verifica sessão ativa no Firebase Auth
3. Se existe sessão: busca dados do usuário
4. Sistema verifica `familyCode`
5. Redireciona para tela apropriada

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 3a | Sem sessão ativa | Redireciona para login |
| 4a | Usuário sem família | Redireciona para onboarding família |
| 4b | Usuário com família | Redireciona para lista de pets |

---

## 2. Família

### UC-006: Criar Família

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-006 |
| **Nome** | Criar Família |
| **Ator Principal** | Membro da Família (autenticado) |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Usuário autenticado<br>- Usuário não pertence a nenhuma família (`familyCode` é null) |
| **Pós-condições** | - Documento de família criado<br>- `familyCode` atribuído ao usuário<br>- Usuário é o `ownerUid` |

**Fluxo Principal:**
1. Usuário acessa tela de onboarding família
2. Usuário escolhe "Criar nova família"
3. Sistema gera código único de 6 caracteres
4. Sistema cria documento em `/families/{familyCode}`
5. Sistema atualiza documento do usuário com `familyCode`
6. Sistema exibe código para compartilhamento
7. Sistema redireciona para lista de pets

**Fluxos de Exceção:**

| ID | Condição | Ação |
|----|----------|------|
| E1 | Código já existe (colisão) | Sistema gera novo código e repete |

**Regras de Negócio:**
- RN01: Código deve ter 6 caracteres alfanuméricos uppercase
- RN02: Código deve ser único
- RN03: `ownerUid` é o UID do criador
- RN04: `createdAt` é timestamp do servidor

---

### UC-007: Entrar em Família Existente

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-007 |
| **Nome** | Entrar em Família Existente |
| **Ator Principal** | Membro da Família (autenticado) |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Usuário autenticado<br>- Usuário não pertence a nenhuma família<br>- Código de família válido |
| **Pós-condições** | - `familyCode` atribuído ao usuário<br>- Usuário pode ver pets da família |

**Fluxo Principal:**
1. Usuário acessa tela de onboarding família
2. Usuário escolhe "Entrar em família existente"
3. Usuário digita código de 6 caracteres
4. Sistema valida formato do código
5. Sistema verifica se família existe
6. Sistema atualiza documento do usuário com `familyCode`
7. Sistema redireciona para lista de pets

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 5a | Família não existe | Sistema exibe "Código inválido" |

**Regras de Negócio:**
- RN01: Código é case-insensitive (convertido para uppercase)
- RN02: Não há limite de membros por família

---

### UC-008: Verificar se Família Existe

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-008 |
| **Nome** | Verificar se Família Existe |
| **Ator Principal** | Sistema (interno) |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Código informado |
| **Pós-condições** | - Retorna true/false |

**Fluxo Principal:**
1. Sistema recebe código de família
2. Sistema consulta `/families/{familyCode}`
3. Sistema retorna se documento existe

---

## 3. Pets

### UC-009: Listar Pets da Família

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-009 |
| **Nome** | Listar Pets da Família |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Usuário autenticado<br>- Usuário pertence a uma família |
| **Pós-condições** | - Lista de pets exibida em tempo real |

**Fluxo Principal:**
1. Usuário acessa tela de pets
2. Sistema inicia stream de `/pets` onde `familyCode == user.familyCode`
3. Sistema exibe lista de pets
4. Quando stream emite atualização: UI atualiza automaticamente

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 3a | Nenhum pet cadastrado | Sistema exibe estado vazio com CTA |

**Regras de Negócio:**
- RN01: Apenas pets do mesmo `familyCode` são listados
- RN02: Lista é ordenada por `createdAt` descendente

---

### UC-010: Cadastrar Pet

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-010 |
| **Nome** | Cadastrar Pet |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore, Firebase Storage |
| **Pré-condições** | - Usuário autenticado com família |
| **Pós-condições** | - Pet criado no Firestore<br>- Foto salva no Storage (se informada) |

**Fluxo Principal:**
1. Usuário toca em "Adicionar Pet"
2. Sistema exibe formulário
3. Usuário preenche: nome*, espécie*, data nascimento, peso
4. Usuário opcionalmente seleciona foto
5. Sistema valida campos obrigatórios
6. Se há foto: sistema faz upload para Storage
7. Sistema cria documento em `/pets`
8. Sistema exibe mensagem de sucesso
9. Lista de pets atualiza automaticamente

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 4a | Foto maior que 5MB | Sistema exibe "Imagem muito grande" |
| 4b | Formato inválido | Sistema exibe "Formato não suportado" |

**Regras de Negócio:**
- RN01: Nome é obrigatório (mín. 1 caractere)
- RN02: Espécie deve ser uma das opções: dog, cat, bird, fish, other
- RN03: Peso deve ser positivo se informado
- RN04: Foto máximo 5MB, formatos: jpg, png, webp
- RN05: `familyCode` é atribuído automaticamente

---

### UC-011: Editar Pet

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-011 |
| **Nome** | Editar Pet |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore, Firebase Storage |
| **Pré-condições** | - Pet existe<br>- Pet pertence à família do usuário |
| **Pós-condições** | - Dados do pet atualizados |

**Fluxo Principal:**
1. Usuário acessa detalhes do pet
2. Usuário toca em "Editar"
3. Sistema exibe formulário preenchido
4. Usuário altera dados desejados
5. Sistema valida campos
6. Sistema atualiza documento
7. Sistema exibe mensagem de sucesso

---

### UC-012: Excluir Pet

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-012 |
| **Nome** | Excluir Pet |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore, Firebase Storage |
| **Pré-condições** | - Pet existe<br>- Pet pertence à família do usuário |
| **Pós-condições** | - Documento do pet removido<br>- Foto removida do Storage<br>- Tarefas do pet removidas |

**Fluxo Principal:**
1. Usuário acessa detalhes do pet
2. Usuário toca em "Excluir"
3. Sistema solicita confirmação
4. Usuário confirma
5. Sistema remove foto do Storage (se existir)
6. Sistema remove tarefas do pet
7. Sistema remove documento do pet
8. Sistema redireciona para lista

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 4a | Usuário cancela | Retorna aos detalhes |

**Regras de Negócio:**
- RN01: Exclusão é cascata (remove tarefas associadas)

---

### UC-013: Upload de Foto do Pet

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-013 |
| **Nome** | Upload de Foto do Pet |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firebase Storage |
| **Pré-condições** | - Pet existe |
| **Pós-condições** | - Foto salva no Storage<br>- `photoUrl` atualizado no pet |

**Fluxo Principal:**
1. Usuário seleciona foto (câmera ou galeria)
2. Sistema valida tamanho e formato
3. Sistema faz upload para `/pets/{petId}/photo`
4. Sistema obtém URL de download
5. Sistema atualiza `photoUrl` no documento do pet

**Regras de Negócio:**
- RN01: Máximo 5MB
- RN02: Formatos: image/jpeg, image/png, image/webp
- RN03: Foto anterior é substituída

---

## 4. Tarefas/Vacinas

### UC-014: Listar Tarefas do Pet

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-014 |
| **Nome** | Listar Tarefas do Pet |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Pet existe<br>- Usuário visualizando detalhes do pet |
| **Pós-condições** | - Lista de tarefas exibida em tempo real |

**Fluxo Principal:**
1. Usuário acessa detalhes do pet
2. Sistema inicia stream de `/pet_tasks` onde `petId == pet.id`
3. Sistema exibe tarefas agrupadas (pendentes/concluídas)
4. Atualizações refletem em tempo real

**Regras de Negócio:**
- RN01: Tarefas pendentes aparecem primeiro
- RN02: Ordenadas por `dueDate` (se existir) ou `createdAt`

---

### UC-015: Criar Tarefa/Vacina

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-015 |
| **Nome** | Criar Tarefa/Vacina |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Pet existe |
| **Pós-condições** | - Tarefa criada |

**Fluxo Principal:**
1. Usuário toca em "Adicionar Tarefa"
2. Sistema exibe formulário
3. Usuário preenche: tipo*, título*, data prevista, observações
4. Sistema valida campos
5. Sistema cria documento em `/pet_tasks`
6. Lista atualiza automaticamente

**Regras de Negócio:**
- RN01: Tipos disponíveis: vaccine, grooming, other
- RN02: Título obrigatório (mín. 1 caractere)
- RN03: `createdBy` é o UID do usuário
- RN04: `done` inicial é false

---

### UC-016: Editar Tarefa

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-016 |
| **Nome** | Editar Tarefa |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Tarefa existe |
| **Pós-condições** | - Tarefa atualizada |

**Fluxo Principal:**
1. Usuário toca na tarefa
2. Sistema exibe detalhes/formulário
3. Usuário altera dados
4. Sistema valida e salva
5. Sistema exibe confirmação

---

### UC-017: Marcar Tarefa como Concluída

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-017 |
| **Nome** | Marcar Tarefa como Concluída |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Tarefa existe<br>- `done` é false |
| **Pós-condições** | - `done` é true |

**Fluxo Principal:**
1. Usuário toca no checkbox/toggle da tarefa
2. Sistema atualiza `done = true`
3. Tarefa move para seção "Concluídas"

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 1a | Tarefa já concluída | Sistema altera `done = false` (reabrir) |

---

### UC-018: Excluir Tarefa

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-018 |
| **Nome** | Excluir Tarefa |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Firestore |
| **Pré-condições** | - Tarefa existe |
| **Pós-condições** | - Tarefa removida |

**Fluxo Principal:**
1. Usuário desliza tarefa ou toca em excluir
2. Sistema solicita confirmação
3. Usuário confirma
4. Sistema remove documento
5. Lista atualiza

---

## 5. Notificações

### UC-019: Avisar Família (Push Notification)

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-019 |
| **Nome** | Avisar Família |
| **Ator Principal** | Membro da Família |
| **Atores Secundários** | Cloud Functions, FCM |
| **Pré-condições** | - Usuário autenticado com família<br>- Pelo menos um membro com token FCM |
| **Pós-condições** | - Push notification enviada para todos os membros |

**Fluxo Principal:**
1. Usuário visualiza detalhes do pet
2. Usuário toca em "Avisar Família"
3. Sistema solicita confirmação com preview
4. Usuário confirma
5. Sistema chama Cloud Function `notifyFamily`
6. Cloud Function busca todos os membros da família
7. Cloud Function envia FCM para todos os tokens
8. Sistema exibe mensagem de sucesso

**Fluxos de Exceção:**

| ID | Condição | Ação |
|----|----------|------|
| E1 | Nenhum membro com token | Sistema exibe "Nenhum membro para notificar" |
| E2 | Cloud Function falhou | Sistema exibe "Falha ao enviar notificação" |

**Regras de Negócio:**
- RN01: Título: "PetKeeper Lite"
- RN02: Body: "{userName} atualizou {petName}"
- RN03: Não notifica o próprio remetente

---

### UC-020: Solicitar Permissão de Notificação

| Campo | Descrição |
|-------|-----------|
| **Identificador** | UC-020 |
| **Nome** | Solicitar Permissão de Notificação |
| **Ator Principal** | Sistema |
| **Atores Secundários** | Sistema Operacional |
| **Pré-condições** | - Primeiro acesso ou permissão não concedida |
| **Pós-condições** | - Permissão concedida ou negada<br>- Token FCM salvo (se concedida) |

**Fluxo Principal:**
1. Usuário faz login
2. Sistema verifica status da permissão
3. Sistema solicita permissão ao SO
4. Usuário concede permissão
5. Sistema obtém token FCM
6. Sistema salva token no documento do usuário

**Fluxos Alternativos:**

| ID | Condição | Ação |
|----|----------|------|
| 4a | Permissão negada | Sistema continua sem notificações |
| 2a | Permissão já concedida | Pula para passo 5 |

---

## Glossário

| Termo | Definição |
|-------|-----------|
| **familyCode** | Código único de 6 caracteres que identifica uma família |
| **FCM** | Firebase Cloud Messaging - serviço de push notifications |
| **Token FCM** | Identificador único do dispositivo para receber notificações |
| **Stream** | Fluxo contínuo de dados em tempo real do Firestore |
| **ownerUid** | UID do usuário que criou a família |

---

## Matriz de Rastreabilidade

| Caso de Uso | Entidades | Repositórios | Use Cases |
|-------------|-----------|--------------|-----------|
| UC-001 | UserEntity | AuthRepository | SignInWithEmail |
| UC-002 | UserEntity | AuthRepository | SignInWithGoogle |
| UC-003 | UserEntity | AuthRepository | SignUpWithEmail |
| UC-004 | - | AuthRepository | SignOut |
| UC-005 | UserEntity | AuthRepository | GetCurrentUser, WatchAuthState |
| UC-006 | FamilyEntity, UserEntity | FamilyRepository | CreateFamily |
| UC-007 | FamilyEntity, UserEntity | FamilyRepository | JoinFamily |
| UC-008 | FamilyEntity | FamilyRepository | CheckFamilyExists |
| UC-009 | PetEntity | PetRepository | WatchPets |
| UC-010 | PetEntity | PetRepository | CreatePet |
| UC-011 | PetEntity | PetRepository | UpdatePet |
| UC-012 | PetEntity, PetTaskEntity | PetRepository, TaskRepository | DeletePet |
| UC-013 | PetEntity | PetRepository | UpdatePet |
| UC-014 | PetTaskEntity | TaskRepository | WatchTasks |
| UC-015 | PetTaskEntity | TaskRepository | CreateTask |
| UC-016 | PetTaskEntity | TaskRepository | UpdateTask |
| UC-017 | PetTaskEntity | TaskRepository | ToggleTaskDone |
| UC-018 | PetTaskEntity | TaskRepository | DeleteTask |
| UC-019 | UserEntity | NotificationRepository | NotifyFamily |
| UC-020 | UserEntity | NotificationRepository | RequestPermission, SetupFcmToken |

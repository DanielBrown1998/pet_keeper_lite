# PetKeeper Lite 🐾

App consumidor para cadastro compartilhado de pets e controle básico de vacinas/tarefas, com foto e sincronização em tempo real.

## 📱 Funcionalidades

- **Autenticação**: Firebase Auth (email/senha + Google Sign-In)
- **Pets (Firestore)**: CRUD completo de pets (nome, espécie, data de nascimento, peso)
- **Foto do pet (Storage)**: Upload e exibição com cache
- **Vacinas/Tarefas (Firestore)**: Adicionar, editar, marcar como concluída
- **Compartilhamento simples**: Código de família para sincronizar dados entre membros
- **Notificação push (FCM)**: Botão "Avisar família" envia push para todos os membros
- **Sync em tempo real**: Listas atualizadas ao vivo via Firestore Streams

## 🏗️ Arquitetura

O projeto utiliza **Clean Architecture** com as seguintes camadas:

```
lib/
├── core/
│   ├── di/                 # Injeção de dependências (GetIt)
│   ├── error/              # Failures e Exceptions
│   ├── router/             # Go_Router configuration
│   └── usecases/           # UseCase base class
├── data/
│   ├── models/             # Models com conversão Firestore
│   └── repositories/       # Implementações dos repositórios
├── domain/
│   ├── entities/           # Entidades de negócio
│   └── repositories/       # Contratos abstratos
└── presentation/
    ├── auth/               # Login, Registro (Bloc)
    ├── family/             # Onboarding família (Bloc)
    ├── pets/               # CRUD de pets (Bloc)
    └── tasks/              # Vacinas/Tarefas (Bloc)
```

### Tecnologias utilizadas:

- **Flutter 3.x** com Dart
- **Bloc/Cubit** para gerenciamento de estado
- **Go_Router** para navegação declarativa
- **GetIt** para injeção de dependências
- **Firebase**: Auth, Firestore, Storage, Functions, Messaging
- **Dartz** para programação funcional (Either<Failure, Success>)

## 🚀 Setup do Projeto

### Pré-requisitos

- Flutter SDK 3.10+
- Node.js 20+
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### 1. Clonar o repositório

```bash
git clone https://github.com/DanielBrown1998/pet_keeper_lite.git
cd pet_keeper_lite
```

### 2. Configurar Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)

2. Ative os seguintes serviços:
   - Authentication (Email/Password e Google)
   - Firestore Database
   - Storage
   - Cloud Functions
   - Cloud Messaging

3. Configure o FlutterFire:

```bash
cd app
flutterfire configure
```

Isso gerará o arquivo `lib/firebase_options.dart` com suas credenciais.

### 3. Configurar Android

Para Google Sign-In no Android:

1. Adicione a SHA-1 do seu app no Firebase Console
2. Baixe o `google-services.json` atualizado
3. Coloque em `app/android/app/google-services.json`

```bash
# Gerar SHA-1
cd app/android
./gradlew signingReport
```

### 4. Configurar iOS (opcional)

1. Baixe `GoogleService-Info.plist` do Firebase Console
2. Coloque em `app/ios/Runner/GoogleService-Info.plist`
3. Configure URL Schemes no Xcode para Google Sign-In

### 5. Instalar dependências

```bash
# Flutter
cd app
flutter pub get

# Cloud Functions
cd ../functions
npm install
```

### 6. Deploy das Security Rules

```bash
# Na raiz do projeto
firebase deploy --only firestore:rules,storage:rules
```

### 7. Deploy das Cloud Functions

```bash
cd functions
npm run build
firebase deploy --only functions
```

## 🧪 Executando com Emuladores

Para desenvolvimento local sem afetar produção:

```bash
# Terminal 1: Iniciar emuladores Firebase
firebase emulators:start

# Terminal 2: Executar o app Flutter
cd app
flutter run
```

**Nota**: Para usar emuladores, adicione no `main.dart`:

```dart
// Adicionar após Firebase.initializeApp()
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

## 📱 Executando o App

```bash
cd app

# Android
flutter run -d android

# iOS
flutter run -d ios

# Com hot reload
flutter run
```

## 🔔 Configurando Push Notifications

### Android

O FCM já está configurado. Certifique-se de ter o `google-services.json`.

### iOS

1. Configure APNs no Apple Developer Portal
2. Faça upload da chave APNs no Firebase Console
3. Adicione capabilities no Xcode: Push Notifications e Background Modes

## 📋 Estrutura de Dados

### Firestore Collections

```
users/{uid}
├── displayName: string
├── email: string
├── familyCode: string
└── fcmTokens: string[]

families/{familyCode}
├── createdAt: timestamp
└── ownerUid: string

pets/{petId}
├── familyCode: string
├── name: string
├── species: string ("dog"|"cat"|"bird"...)
├── birthDate: timestamp?
├── weightKg: number?
├── photoUrl: string?
└── createdAt: timestamp

pet_tasks/{taskId}
├── petId: string
├── type: string ("vaccine"|"grooming"|"other")
├── title: string
├── dueDate: timestamp?
├── notes: string?
├── createdBy: string
├── createdAt: timestamp
└── done: boolean
```

## 🔐 Segurança

### Firestore Rules

- Usuários só acessam seu próprio documento
- Pets e tarefas são isolados por `familyCode`
- Validação de `familyCode` em todas as operações

### Storage Rules

- Upload limitado a 5MB
- Apenas imagens aceitas
- Requer autenticação

### Melhorias futuras sugeridas:

- Custom Claims para validação server-side do familyCode
- Rules mais estritas em `pet_tasks` validando ownership do pet
- Rate limiting nas Cloud Functions

## 🎬 Fluxos de UX

1. **Onboarding** → Criar ou entrar com `familyCode`
2. **Lista de Pets** → Stream em tempo real
3. **Detalhe do Pet** → Ver info + CRUD de vacinas/tarefas
4. **Avisar Família** → Push notification para todos os membros

## 🧪 Testes

```bash
cd app

# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```


### Código refatorado manualmente:

- **Segurança**: Adicionei validações extras nas rules e na Cloud Function
- **Performance**: Implementei streams ao invés de futures para dados em tempo real
- **UX**: Adicionei estados de loading, empty e error em todas as telas
- **Type Safety**: Corrigi tipagens e adicionei null checks onde necessário

## 📹 Vídeo de Demonstração

[Link do vídeo aqui - máximo 8 minutos]

Demonstra:
1. Login com email/senha e Google
2. Criar/entrar em família com código
3. CRUD de pets com foto
4. CRUD de vacinas/tarefas em tempo real
5. Push notification "Avisar Família"

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.


## 🤖 Como usei o Cursor

## Prompts utilizados
1. De acordo com os requisitos prepare um projeto com base no clean code, utilizando o clean architecture, Bloc para gerenciamento de estado, Go_Router para navegacao, GetIt para injecao de dependencia.

2. Voce quebrou alguns principios do SOLID, 
Bloc contem logica e gerencia o estado (violou o SRP), o RepositoryPattern esta inserido diretamente no Bloc 
para resolver crie os casos de uso e mova a logica para la, ponha os arquivos do caso de uso no pasta de dominio, 
aqui voce quebrou o ISP, crie um source (contrato e implementacao para acessar o firebase).   

Repositorios retornan as entidades anemicas
Source retornam os Models

Ademais, voce tambem nao instanciou todos os Blocs no topo da arvore com o BlocProvider, utilize o GetIt apenas para instanciar os sources, repositories e usecases, os BLocs ficarao no topo da arvore, e receberam suas dependencias buscando as intancias no GetIt, (tudo lazy)

A estrutura do dartz vai para o usecase, em caso de erro retorne as falhas ja escritas

### ajuste manual: 
O agente criou as dependencias no main diretamente, coloquei todos dentro do BlocProvider para tornarem-se lazy e nao prejudicar a inicializacao do app.

3.Ok, agora eu tenho mais uma questao, os estados do Bloc estao definidos como const dentro de seus respectivos state, defina uma sealed class e a partir dos tipos AuthUnknowState, AuthLoadingState, AuthAuthenticatedState ... entao ai voce define o status da autenticacao, o usuario se houver e o erro caso haja. 

 ### O que foi ajustado
----------------------------- ANTES -----------------------------------:   
enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  const AuthState.unknown() : this();

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(UserEntity user)
    : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated([String? error])
    : this(status: AuthStatus.unauthenticated, error: error);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasFamily =>
      user?.familyCode != null && user!.familyCode!.isNotEmpty;

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
----------------------------------DEPOIS -----------------------------------|


sealed class AuthState extends Equatable {
  const AuthState();

  /// Retorna o usuário se estiver autenticado, null caso contrário
  UserEntity? get user => null;

  /// Retorna o erro se houver, null caso contrário
  String? get error => null;

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => this is AuthAuthenticatedState;

  /// Verifica se está carregando
  bool get isLoading => this is AuthLoadingState;

  /// Verifica se o usuário pertence a uma família
  bool get hasFamily =>
      user?.familyCode != null && user!.familyCode!.isNotEmpty;
}

/// Estado inicial - ainda não verificou autenticação
final class AuthUnknownState extends AuthState {
  const AuthUnknownState();

  @override
  List<Object?> get props => [];
}

/// Estado de carregamento durante operações de autenticação
final class AuthLoadingState extends AuthState {
  const AuthLoadingState();

  @override
  List<Object?> get props => [];
}

/// Estado autenticado com usuário logado
final class AuthAuthenticatedState extends AuthState {
  @override
  final UserEntity user;

  const AuthAuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado não autenticado, opcionalmente com mensagem de erro
final class AuthUnauthenticatedState extends AuthState {
  @override
  final String? error;

  const AuthUnauthenticatedState([this.error]);

  @override
  List<Object?> get props => [error];
}

4. todos esses widget selecionados, deveriam ser classes de widgets, e nao funcoes, o flutter deve renderizalos e criar seu proprio element na arvore de elementos, do modo como esta o app tera menos performance, entao escreva esses widgets em uma pasta widget dentro de pets/pages/widgets, mova suas dependencias para la tambem (como algum dialog ou codigo sincrono)

### O problema:

  declarar widgets dessa forma no Flutter, ocorrera um perda de performance, porquanto ao utilizar o setState no topo, todos os widgets serao passiveis de rebuild, o Framework verificara cada um deles, ja que eles sao filhos do widget que fora marcado como sujo na arvore, entao o framework verificara cada um deles


  Widget _buildAppBar(BuildContext context, PetEntity pet) {}

  Widget _buildPetInfo(BuildContext context, PetEntity pet) {}

  Widget _buildInfoRow(IconData icon, String label, String value) {}

  Widget _buildTasksSection(BuildContext context) {}

  Widget _buildTaskItem(BuildContext context, PetTaskEntity task) {}

  Widget _buildTaskTypeChip(TaskType type) {}

  void _showDeleteDialog(BuildContext context) {}

  void _showNotifyDialog(BuildContext context, PetEntity pet) {}

### Solucao  


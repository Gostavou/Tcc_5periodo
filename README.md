# Projeto Financeiro Pessoal - TCC 5º Período

## 📌 Visão Geral

Aplicativo de controle financeiro pessoal desenvolvido como Trabalho de Conclusão de Curso (TCC) para o 5º período. Permite o gerenciamento de finanças pessoais com integração a serviços em nuvem.

## ✨ Funcionalidades Principais

- 🔐 Autenticação com Firebase Auth e Google Sign-In
- 💰 Controle de transações (receitas/despesas)
- 📊 Dashboard com gráficos interativos (Syncfusion Charts)
- 🧮 Calculadora de juros compostos
- 🎯 Acompanhamento de metas financeiras
- 📈 Cotações de moedas em tempo real
- ☁️ Sincronização com Firebase Firestore

## ⚙️ Em desenvolvimento

Algumas funcionalidades ainda estão em fase de testes/ajustes:

- 🔧 Correção de erros no carregamento e exibição de **imagens de perfil**  
- 🔄 Finalização do **login com Google**  
- 💵 Implementação da **adição de saldo inicial** pelo próprio usuário (atualmente fixado em R\$ 5.000 fictícios)
- 🚫 Correção do problema onde, ao **deslogar e logar com outro usuário**, os dados anteriores ainda aparecem (será implementada limpeza automática dos dados locais no logout)


## 🛠 Tecnologias Utilizadas

### Frontend
- Flutter 3.0+
- Dart 3.0+
- Pacotes principais (pubspec.yaml):
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    fl_chart: ^0.70.2
    flutter_svg: ^1.1.6
    font_awesome_flutter: ^10.7.0
    provider: ^6.0.0
    shared_preferences: ^2.2.2
    uuid: ^4.5.1
    http: ^1.3.0
    intl: 0.18.1
    firebase_core: ^3.12.1
    firebase_storage: ^12.4.6
    firebase_auth: ^5.5.1
    cloud_firestore: ^5.6.8
    flutterfire_cli: any
    image_picker: ^1.1.2
    flutter_local_notifications: ^18.0.1
    google_fonts: ^6.1.0
    syncfusion_flutter_charts: ^29.1.40
    google_sign_in: ^6.1.4

  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^5.0.0
    flutter_launcher_icons: ^0.13.1

# 💰 App de Controle Financeiro

Um aplicativo Flutter para controle de finanças pessoais, com registro de despesas, lucros, metas e cotações de moedas. Simples, visual e eficiente — pensado para ajudar tanto no uso pessoal quanto familiar.

---

## 🛠️ Backend & Serviços

- 🔐 **Firebase Authentication** – Login/registro de usuários  
- 🔥 **Cloud Firestore** – Banco de dados NoSQL em tempo real  
- ☁️ **Firebase Storage** – Armazenamento de imagens de perfil  
- 🌐 **Google Cloud Platform** – Infraestrutura de serviços  
- 📁 **Google Drive API** – Integração futura com backups  
- 💱 **ExchangeRate-API** – Cotações de moedas em tempo real  

---

## 📱 Estrutura do Projeto

### 🧭 Telas Principais

- `main.dart`: Ponto de entrada do aplicativo  
- `dashboard_screen.dart`: Tela principal com resumo financeiro  
- `login_screen.dart` / `register_screen.dart`: Autenticação de usuários  
- `add_expense_screen.dart` / `add_profit_screen.dart`: Registro de transações  
- `history_screen.dart`: Histórico completo de transações  
- `currency_screen.dart`: Cotações e conversões de moedas  
- `goals_screen.dart`: Gerenciamento de metas financeiras  
- `interest_calculator_screen.dart`: Calculadora de juros  
- `settings_screen.dart`: Preferências e configuração do usuário  

### 🔄 Providers (Gerenciamento de Estado)

- `auth_provider.dart`: Autenticação  
- `user_provider.dart`: Dados do usuário  
- `expense_provider.dart`: Transações financeiras  
- `currency_provider.dart`: Cotações e moedas  
- `goal_provider.dart`: Metas financeiras  
- `theme_provider.dart`: Alternância entre temas claro/escuro  

---

## 🔌 API de Cotações

O app utiliza a **ExchangeRate-API** via pacote `http` para obter as taxas de câmbio atualizadas em tempo real.

---

## 🧰 Configuração do Ambiente

### ✅ Pré-requisitos

- Flutter SDK `3.0+`  
- Dart `3.0+`  
- Android Studio ou Xcode  
- Conta Firebase com:
  - Authentication ativado
  - Firestore configurado
  - Storage ativado  

### 📦 Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/Gostavou/Tcc_5periodo.git
   cd Tcc_5periodo

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase:**

   Adicione os arquivos:

   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

   Ative os serviços no Console Firebase.

4. **Configure a API de cotações:**

   Crie um arquivo `.env` na raiz do projeto  
   Adicione sua chave:

   ```ini
   EXCHANGE_RATE_API_KEY=sua_chave_aqui
   ```

5. **Gere os ícones do app:**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

6. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

---

## ⚠️ Solução de Problemas

### 🔍 Verifique as versões:
```bash
flutter doctor
flutter --version
dart --version
```

### 🔁 Atualize dependências:
```bash
flutter pub upgrade
```

### 🛠 Problemas comuns:

- **Cotações:** Verifique chave e conexão com a internet  
- **Firebase:** Revise regras de segurança no Firestore  
- **Dependências:** Revise versões compatíveis no `pubspec.yaml`

---

## 🧾 Licença

Este projeto é de uso acadêmico e pessoal.  
Sinta-se à vontade para estudar e adaptar ideia.

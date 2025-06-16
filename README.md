# Controle Financeiro - App Flutter
## Tecnologias Utilizadas

- Flutter (SDK para apps multiplataforma)
- Firebase (Autenticação, Firestore para banco de dados)
- Provider (Gerenciamento de estado)
- intl (Internacionalização e formatação de datas)
- Outros pacotes Flutter para UI e funcionalidades

## Como Rodar o Projeto

### Requisitos

Antes de começar, você precisa ter instalado no seu computador:

- Flutter SDK (versão estável mais recente recomendada)
- Android Studio ou VS Code com extensões Flutter e Dart instaladas
- Um dispositivo físico Android/iOS ou um emulador/simulador configurado
- Conta no Firebase (Google) para conectar ao backend

### Passos para configurar

1. Clone o repositório
git clone https://github.com/Gostavou/Tcc_5periodo.git
cd Tcc_5periodo

2. Instale as dependências
flutter pub get

3. Configure o Firebase
Este projeto já possui o arquivo firebase_options.dart gerado para a configuração padrão. Porém, caso queira usar sua própria conta Firebase, siga os passos:

Crie um projeto no Console Firebase
Ative Autenticação por Email e Google
Crie um Firestore no modo "produção" ou "teste" conforme preferir
Baixe os arquivos de configuração para Android (google-services.json) e iOS (GoogleService-Info.plist)
Siga a documentação oficial FlutterFire para adicionar esses arquivos no projeto

Gere o arquivo firebase_options.dart com o comando:
flutterfire configure

4. Execute o app
Conecte um dispositivo ou inicie um emulador e rode:
flutter run

## Estrutura do Projeto
lib/
models/ - Modelos de dados (usuário, transação, meta)
providers/ - Gerenciamento de estado com Provider (usuário, despesas, metas, tema, etc)
screens/ - Telas do app (login, cadastro, dashboard, histórico, metas, perfil)
services/ - Serviços para comunicação com Firebase e outras APIs
firebase_options.dart - Configuração Firebase gerada
main.dart - Arquivo principal que inicializa o app e providers

## Funcionalidades
- Registro e login de usuários com Firebase Authentication (Email e Google)
- Cadastro de despesas e receitas com data, valor e categoria
- Visualização de histórico de transações ordenado por data
- Gestão de metas financeiras
- Suporte a múltiplas moedas estrangeiras
- Filtros por período (mês, semana, ano)
- Atualização e visualização do perfil do usuário com foto


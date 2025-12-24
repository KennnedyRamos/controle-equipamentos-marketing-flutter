# 📦 Controle de Equipamentos e Materiais de Marketing

Aplicativo mobile desenvolvido em **Flutter**, focado no controle interno de **equipamentos** e **materiais de marketing**, com autenticação, persistência de dados no **Firebase Firestore**, imagens salvas localmente no dispositivo e **exportação para Excel (.xlsx)**.

Projeto pronto para publicação na **Google Play Store**.

---

## 🚀 Funcionalidades

### 📋 Equipamentos
- Cadastro, edição e exclusão de equipamentos
- Tipos específicos (ex: Refrigerador, Rack, Luminoso, etc.)
- Controle de quantidade
- Upload e visualização de imagem local
- Exportação da lista de equipamentos para **Excel**

### 📦 Materiais de Marketing
- Cadastro, edição e exclusão
- Controle de quantidade
- Upload e visualização de imagem local
- Exportação para **Excel**

### 📥 Exportação para Excel
- Geração de arquivos `.xlsx`
- Salvamento direto na pasta **Downloads** (Android)
- Uso do **MediaStore**
- Funciona offline (sem serviços pagos)

---

## 🛠️ Tecnologias Utilizadas

- **Flutter / Dart**
- **Firebase Authentication**
- **Firebase Firestore**
- **Image Picker**
- **Excel (flutter_excel)**
- **Android MediaStore**
- **Material Design**

---

## 📂 Estrutura do Projeto

```bash
lib/
 ├── models/
 │   ├── equipamento_model.dart
 │   └── material_marketing_model.dart
 │
 ├── screens/
 │   ├── cadastrar_equipamento_screen.dart
 │   ├── cadastrar_material_marketing_page.dart
 │   ├── editar_equipamento_screen.dart
 │   ├── editar_material_marketing_screen.dart
 │   ├── equipamentos_screen.dart
 │   ├── excluir_equipamento_screen.dart
 │   ├── home_screen.dart
 │   ├── login_screen.dart
 │   ├── materiais_marketing_screen.dart
 │   └── visualizar_imagem_screen.dart
 │
 ├── services/
 │   ├── firestore_service.dart
 │   ├── image_service.dart
 │   ├── exportar_excel_io.dart
 │   ├── exportar_excel_service.dart
 │   ├── exportar_material_marketing_excel_io.dart
 │   └── exportar_material_marketing_excel_service.dart
 │
 ├── theme/
 │   └── theme_controller.dart
 │
 ├── widgets/
 │   ├── animated_3d_button.dart
 │   └── image_preview_widget.dart
 │
 ├── firebase_options.dart
 └── main.dart
```
---

### 🔐 Segurança & Boas Práticas

- 🔑 Autenticação segura utilizando Firebase Authentication

- 🛡️ Regras avançadas de segurança no Firestore, com:

- Validação de tipos

- Controle de acesso por usuário autenticado

- Prevenção de escrita de dados inválidos

- ✅ Validação de dados no backend via Firestore Rules

- 🚫 Proteção de informações sensíveis através de .gitignore bem configurado

- 📦 Aplicação pronta para produção seguindo padrões exigidos pela Play Store

- ⚙️ Arquitetura & Configuração do Firebase

---

### Projeto estruturado seguindo separação clara de responsabilidades:

- Models

- Services

- Screens

- Widgets

---

### Integração completa com Firebase:

- Authentication

- Firestore Database (tempo real)


- Configuração do app Android com assinatura digital (keystore)

- Passos para configuração local

- Criar um projeto no Firebase Console

- Ativar:

- Authentication

- Firestore Database

- Registrar o aplicativo Android

- Adicionar o arquivo:

```android/app/google-services.json```


-⚠️ Arquivo sensível — não versionado no GitHub

---

### 📦 Build & Publicação

- Aplicação preparada para ambiente de produção:

- Gerar APK (testes internos)
```bash
flutter build apk --release
```

- Gerar AAB (publicação na Play Store)
```bash
flutter build appbundle
```

- 📁 Outputs:

```build/app/outputs/```

---

### 📱 Plataformas Suportadas

- ✅ Android

- ❌ iOS

- Não configurado devido ao uso de MediaStore para exportação de arquivos

- 📊 Funcionalidades Técnicas Relevantes

- 📦 CRUD completo com Firestore

- 🔄 Atualização em tempo real

- 📸 Captura e seleção de imagens (câmera e galeria)

- 🖼️ Visualização de imagens em tela cheia (zoom)

- 📊 Exportação de dados para Excel (.xlsx) sem dependência de backend

- 📂 Armazenamento local eficiente para imagens

- 🔐 Controle de acesso por autenticação

---

### 📌 Observações Técnicas Importantes

- As imagens são armazenadas localmente no dispositivo

- Apenas o caminho da imagem é salvo no Firestore

- Exportação para Excel funciona offline

- Projeto utiliza apenas bibliotecas gratuitas

- Código preparado para fácil manutenção e escalabilidade


---

### 👨‍💻 Autor

Desenvolvido por Kennedy Ramos
Desenvolvedor Flutter 🚀

🔗 GitHub: https://github.com/KennnedyRamos

🔗 LinkedIn: https://www.linkedin.com/in/kennedy-ramos/

---

### 📄 Licença

- Projeto de uso interno.
- Distribuição não autorizada sem consentimento do autor.

---

## 🔥 Quer deixar ainda mais profissional?
Posso:
- Criar versão **em inglês**
- Ajustar para **portfólio**
- Adicionar **badges** (Flutter, Firebase, Android)
- Criar um **CHANGELOG.md**
- Revisar antes do push final no GitHub

É só falar 👊

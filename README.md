# Movie Explorer - Prueba Técnica

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)

Movie Explorer es una aplicación móvil desarrollada con Flutter que te permite explorar información sobre películas, incluyendo detalles, puntuaciones y más.

## 📌 Características

- Explorar películas populares y próximos estrenos
- Ver detalles completos de cada película
- Interfaz de usuario intuitiva y responsive
- Gestión de estado con Provider
- Consumo de API REST con el paquete http

## 📦 Paquetes utilizados

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2
  provider: ^6.1.4
  http: ^1.3.0
  flutter_dotenv: ^5.2.1
  flutter_launcher_icons: ^0.14.3
  path_provider: ^2.1.5
  connectivity_plus: ^6.1.3
  path: ^1.9.1
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0  # Análisis estático de código
```

## 🚀 Ejecutar en Local

### 1.- Requisitos

* Flutter SDK instalado (versión 3.5.2 o superior)

* Dart SDK

* Dispositivo emulado o físico conectado

### Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/movie_explorer.git
cd movie_explorer
```

### Obtener dependencias

```bash
flutter pub get
```

### Ejecutar app

```bash
flutter run
```

### Ejecutar en Google IDX (Mucho mas fácil)

- Te diriges a idx.google.com
- Clonas el repositorio en un nuevo entorno
- Ejecutas la App como si estuvieras desarrollando en local

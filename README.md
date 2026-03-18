# ReadCar — Monitor OBD2 para Android

Aplicación Flutter de diagnóstico vehicular en tiempo real mediante el protocolo **OBD2/ELM327** por Bluetooth BLE. Permite leer parámetros del motor, detectar códigos de falla (DTC), estimar consumo de combustible y registrar el historial de viajes.

---

## Pantallas

| Conexión | Dashboard | Diagnóstico | Historial |
|---|---|---|---|
| Escaneo BLE, calidad de señal RSSI | Velocidad, RPM, temperatura, combustible | Códigos DTC con búsqueda en Google/YouTube | Registro de viajes con consumo |

---

## Funcionalidades

- **Conexión Bluetooth BLE** al adaptador ELM327 con indicador de calidad de señal (Excelente / Buena / Regular / Débil)
- **Dashboard en tiempo real**: velocidad, RPM (gauge), temperatura del refrigerante, nivel de combustible, carga del motor
- **Diagnóstico de fallas (DTC)**: lectura de códigos OBD2, descripción en español, categoría (Powertrain / Chassis / Body / Network)
  - Toca cualquier código para buscar causas y solución en **Google** o **YouTube**
  - Opción para copiar el código al portapapeles
  - Botón para limpiar los códigos del vehículo
- **Consumo de combustible**: estimación de L/100 km, km/L y costo por hora
- **Historial de viajes**: guardado local con Hive (persiste entre sesiones)
- **Modo Demo**: simula un ciclo de manejo completo para pruebas sin hardware

---

## Arquitectura

```
lib/
├── core/
│   ├── constants/       # Comandos OBD2, configuración, Hive boxes
│   ├── errors/          # Either monad, jerarquía de Failures
│   ├── theme/           # Colores y tema oscuro
│   └── utils/           # Parser OBD2, calculadora de combustible, decodificador DTC
├── data/
│   ├── datasources/     # Bluetooth BLE, OBD2 ELM327, Hive local
│   ├── models/          # Modelos Hive con TypeAdapters generados
│   └── repositories/    # Implementaciones reales + mocks para demo
├── domain/
│   ├── entities/        # VehicleData, DtcCode, TripSession, BleDevice
│   ├── repositories/    # Interfaces abstractas
│   └── usecases/        # Casos de uso por feature
└── presentation/
    ├── navigation/      # GoRouter con ShellRoute
    ├── providers/       # Riverpod providers (DI root)
    └── screens/         # Splash, Conexión, Dashboard, Diagnóstico, Historial
```

**Stack tecnológico:**
- State management: `flutter_riverpod` 2.5
- Bluetooth: `flutter_blue_plus` 1.32
- Persistencia: `hive_flutter` 1.1
- Navegación: `go_router` 13.2
- Gráficas: `fl_chart` 0.68
- URLs externas: `url_launcher` 6.3

---

## Modo Demo vs. Dispositivo Real

Por defecto la app corre en **modo Demo** (sin necesidad de hardware). Para usar con un adaptador ELM327 real:

### 1. Abre el archivo de configuración

```
lib/core/constants/app_config.dart
```

### 2. Cambia `kDemoMode` de `true` a `false`

```dart
// ANTES (modo demo / emulador)
const bool kDemoMode = true;

// DESPUÉS (dispositivo real con ELM327)
const bool kDemoMode = false;
```

### 3. Conecta el adaptador

1. Enchufa el adaptador ELM327 Bluetooth al puerto OBD2 del vehículo (debajo del volante)
2. Enciende el contacto del auto (posición ACC o motor encendido)
3. Empareja el adaptador en los ajustes Bluetooth del teléfono (si es BT clásico)
4. Abre la app → pantalla **Conectar OBD2** → pulsa **Buscar dispositivos**
5. Selecciona tu adaptador de la lista

> **Nota:** En Android 12+ la app solicita permisos `BLUETOOTH_SCAN` y `BLUETOOTH_CONNECT` al iniciar. En Android 10/11 también solicita ubicación (requerido por la API de BLE).

---

## Instalación y ejecución

```bash
# Clonar el repositorio
git clone https://github.com/xavierquiroz1998/Read_car.git
cd Read_car

# Instalar dependencias
flutter pub get

# Generar adaptadores Hive (si no existen los .g.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Correr en modo debug (emulador o dispositivo)
flutter run
```

**Requisitos:**
- Flutter SDK >= 3.3.0
- Android SDK con API 21+ (target API 34)
- NDK 27.0.12077973 (configurado en `android/app/build.gradle.kts`)

---

## Tests

```bash
flutter test
```

148 tests unitarios que cubren:
- Parser OBD2 (velocidad, RPM, temperatura, combustible, DTCs)
- Calculadora de consumo de combustible
- Decodificador de códigos DTC
- Entidades del dominio (`VehicleData`, `DtcCode`)
- Monad `Either` y jerarquía de `Failures`

---

## Permisos Android

| Permiso | Uso |
|---|---|
| `BLUETOOTH_SCAN` | Escanear dispositivos BLE (Android 12+) |
| `BLUETOOTH_CONNECT` | Conectar al adaptador (Android 12+) |
| `BLUETOOTH` / `BLUETOOTH_ADMIN` | Compatibilidad Android 10/11 |
| `ACCESS_FINE_LOCATION` | Requerido por la API BLE en Android < 12 |
| `INTERNET` | Apertura de búsquedas en Google/YouTube |

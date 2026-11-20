# CooPay — App móvil (Flutter)

Primer lote del frontend Flutter de CooPay, siguiendo `project-playbook-main`
(`01-stack-estandar.md` → Flutter; `02-arquitectura-base.md` → capas
`screens/` → `repositories/` → `models/`).

## Estado: compila y corre, verificado

Flutter ya está instalado y el proyecto fue validado de punta a punta en
esta máquina:

- `flutter pub get` — sin errores.
- `flutter analyze` — 0 errores, 0 warnings (quedan unas notas `info` de
  estilo, ver abajo).
- `flutter create --platforms=web,android,ios .` ya se corrió, así que
  `android/`, `ios/` y `web/` existen y están listos para compilar.
- `flutter build web --release` — build exitoso.
- Verificado visualmente en navegador: Landing carga con logo, título y los
  dos botones; `Ya tengo cuenta` navega a `Iniciar sesión` y esa pantalla
  también renderiza bien (campo de correo + botón Continuar).

Nota para quien siga en otra máquina: Flutter quedó instalado en
`C:\flutter` pero **no se agregó al PATH del sistema** (cambio que requiere
permisos que no se autorizaron en esa sesión). Para usarlo ahí hay que
either (a) agregar `C:\flutter\bin` al PATH manualmente, o (b) invocar
`C:\flutter\bin\flutter.bat` con ruta completa.

Quedan 2 notas `info` de `flutter analyze` sin resolver, a propósito:
`package:flutter/material.dart` está marcado como deprecado a favor de un
paquete nuevo `material_ui` — decidí NO migrar todavía porque ese paquete es
demasiado nuevo/experimental para un proyecto que recién arranca; se
revisita más adelante si el equipo lo pide.

## Primer paso en una máquina nueva

```bash
cd coopay_flutter
flutter pub get
flutter run
```

(`android/`, `ios/` y `web/` ya están generados y versionados — no hace
falta correr `flutter create` de nuevo.)

## Qué decisiones tomé (y por qué)

El playbook dice "Flutter" pero no entra en detalle de qué librería usar
para cada cosa dentro de Flutter — estas quedan documentadas aquí, siguiendo
el mismo criterio del playbook de "documenta la decisión":

| Capa | Elegí | Por qué |
|---|---|---|
| Manejo de estado | `provider` | Es el más simple de los oficiales de Flutter — "el mínimo necesario", misma filosofía que el playbook pide para el estado de cliente en web |
| HTTP | `http` | Paquete oficial, sin curva de aprendizaje extra; alcanza para lo que necesita esta app |
| Tipografía | `google_fonts` | Carga League Spartan + Plus Jakarta Sans sin tener que empaquetar los archivos de fuente |
| Routing | `Navigator` con rutas por `MaterialPageRoute`, sin paquete de router | Con el número de pantallas de hoy no hace falta `go_router` — se agrega después si realmente hace falta deep-linking |

## Por qué todo es mock todavía

El backend de CooPay no existe aún — tu compañero apenas va a empezar
("muy bien, en un momento empiezo con el back..."). Mientras tanto:

- `lib/config/app_config.dart` tiene `useMockData = true` por default.
- Cada repositorio (`AuthRepository`, `CuentasRepository`,
  `ComerciosRepository`) es una interfaz abstracta + una implementación
  `Mock...` que regresa los mismos datos de ejemplo que ya tenía el
  prototipo (Nicolás Ibarra, Caja Hipódromo $12,480.50, Caja Genera
  $3,210.00, Tienda CoopMarket, Farmacia Norte).
- `lib/repositories/api_client.dart` ya tiene el envoltorio HTTP listo
  (headers, bearer token) para cuando haya Swagger real — falta escribir
  `HttpCuentasRepository`, `HttpAuthRepository`, etc. que implementen las
  mismas interfaces, y cambiar el `Provider<...>` en `main.dart` para que
  use esas en vez de las `Mock...`. Ningún `screen/` debería necesitar
  cambios para ese switch — por diseño.

## Qué pantallas ya existen vs. qué falta

**Ya implementadas** (flujo núcleo + segundo lote de transacciones):

- `Landing` → `Login` / `Registro` (nombre, correo, teléfono, contraseña, términos) → `Onboarding` biométrico
- `Inicio` (dashboard con las 2 cuentas, accesos rápidos, Mis comercios / Comercios que superviso, campana con badge de no leídas)
- `Cuentas` (lista) → `Detalle de cuenta` (saldo, compartir, número/CLABE revelable, movimientos, botón "Movimientos" hace scroll a la sección)
- `Comercios` (lista Mis comercios / Comercios que superviso)
- `Perfil` (datos básicos, Notificaciones, cerrar sesión)
- `Pagar QR`: `EscanearQrScreen` (demo sin cámara — elige comercio de una lista) → `ConfirmarPagoScreen` → `ComprobanteScreen`
- `Transferir`: `TransferirScreen` (CLABE + destinatario + monto) → `ComprobanteScreen` — accesible desde Inicio, desde Detalle de cuenta (origen precargado) y desde el botón de escanear
- `Vincular otra cuenta de ahorro`: `VincularCuentaScreen` (cuenta existente vs. institución nueva) → `VincularDocumentosScreen` (checklist de documentos) para institución nueva
- `Notificaciones`: lista con estado leído/no leído persistente en memoria
- Navegación inferior compartida (`BottomNavBar`) con el botón de escanear QR elevado, ahora conectado en las 4 pantallas raíz
- Saldos y movimientos mutables en el mock (`MockCuentasRepository`): pagar/transferir sí descuentan saldo y aparecen en el historial, con reintento idempotente y validación de saldo insuficiente

- `Panel de comercio` (administrador): ventas de hoy, cobros realizados, ticket promedio, cobros del día, accesos a QR/Supervisores/Datos fiscales — todo calculado desde datos reales mutables, no texto fijo
- `Cobrar con QR` (`CobroQrScreen`): pantalla en vivo con QR, "Simular cobro recibido" → overlay de pago recibido → detalle
- `Mi QR físico` (`MostradorQrScreen`): QR permanente en 3 formatos (Cartel/Tarjeta/Solo QR) con descargar/compartir/imprimir (feedback transitorio, sin integración real de archivos)
- `Historial de ventas` con filtros por periodo (Hoy/7 días/Mes) y estado (Todas/Aprobadas/Reembolsadas) → `Detalle de transacción` con reembolso real (descuenta de las estadísticas del panel al volver)
- `Datos fiscales y del negocio`: formulario editable (razón social, RFC, dirección, régimen) con confirmación
- `Panel de supervisor` (solo lectura): mismo panel sin folios con nombre de socio — por diseño, un supervisor nunca ve la identidad del cliente, solo folio/hora/estado/monto
- `Supervisores`: lista con revocar (confirmación en bottom sheet) → `Invitar supervisor` (qué puede ver / qué no puede hacer) → `Invitación recibida` (aceptar/rechazar), con aceptar agregando el comercio a "Comercios que superviso" en vivo
- Banner de "Invitaciones pendientes" en la pantalla Comercios, y los comercios de Inicio/Comercios ya navegan a su panel correspondiente según el rol

- `Habilitar un nuevo comercio`: wizard de 3 pasos (cuenta receptora real desde `CuentasRepository` → datos del negocio → revisar y confirmar) que crea el comercio de verdad y lo agrega a "Mis comercios"
- `Ajustes y seguridad`: toggles de biometría/ocultar saldos → `Cambiar PIN` (flujo de 3 pasos con teclado numérico y validación de coincidencia) → `Dispositivos y sesiones` (cerrar sesión individual o todas) → `Términos y Aviso de Privacidad` (2 pestañas)
- `Ayuda y soporte`: Llamar/WhatsApp/Chat en vivo (simulados, sin integración real) + FAQ con acordeón
- `Notificaciones del comercio`: pantalla propia (distinta a la de socio) con pestañas Pagos recibidos / Retiros procesados / Avisos del sistema, folio real ligado a cada venta, "Marcar todo como leído"

- `Onboarding` (CU-01): resultó que SÍ está conectado al flujo real — `Registro.dc.html` enlaza a `Onboarding.dc.html` aunque el canvas no lo marcaba como interactivo. 3 pasos: `Verifica tu identidad` (captura de INE simulada, sin integración real de cámara) → `Verificación facial` (prueba de vida simulada) → `Crea tu PIN transaccional` (mismo patrón de teclado que Cambiar PIN) → `¡Cuenta verificada!`, que ahora sí crea la sesión real (antes `Registro` saltaba directo a Inicio sin pasar por aquí)

- `Perfil del comercio`: hub nuevo, accesible desde el ícono de persona en Panel de comercio (solo Administrador). Agrupa Datos del comercio, Sucursales, Corte de caja, Supervisores, PIN de seguridad, Ayuda y soporte, Cerrar sesión
- `Sucursales`: varias sucursales por comercio, cada una con su propio QR de mostrador para imprimir (reutiliza `MostradorQrScreen`) + alta de sucursal nueva
- `Corte de caja`: resumen de cobros del día (total, cobros, ticket promedio), "Exportar reporte (PDF)" simulado, "Cerrar caja" con confirmación — el cierre es solo un registro, los cobros nuevos del día siguen llegando con normalidad
- `Ayuda y soporte` del comercio: pantalla propia (distinta a la del socio) con "Reportar un problema con un cobro" (folio + descripción), Llamar/Chat simulados, y FAQ propio de temas de comercio

**Decisiones de alcance en este lote** — el prototipo original dibuja un sistema más amplio (roles Administrador/Cajero/Supervisor intercambiables, empleados con permisos, turnos de caja, retiros a cuenta bancaria externa) que no encaja con el esquema de base de datos actual (`RolComercio` solo tiene `administrador`/`supervisor`, sin `Cajero`). Para no inventar un modelo de datos paralelo, se simplificó:

- **Gestión de empleados / Agregar empleado / Editar permisos** (`GestionEmpleados`, `AgregarEmpleado`, `EditarPermisos` en el prototipo) — no se construyeron: dependen por completo del rol Cajero, que no existe en el esquema. Si el equipo confirma que se necesita, hay que agregar primero el rol a `prisma/schema.prisma`
- **PIN de seguridad del comercio** (`ConfiguracionPin.dc.html`, con un patrón visual de 3 tarjetas simultáneas) — no se duplicó como pantalla nueva; "PIN de seguridad" en Perfil del comercio reutiliza la misma `CambiarPinScreen` del socio, porque comercio y socio comparten la misma sesión y el mismo PIN — tener dos pantallas de PIN distintas para la misma cuenta habría sido confuso
- **Retiros** (`GestionRetiros.dc.html`) — no se construyó como pantalla aparte: en este modelo el dinero de las ventas ya cae en tiempo real a la cuenta receptora del socio (ej. Caja Hipódromo), así que "retirar" es simplemente hacer una Transferencia normal desde esa cuenta — ya implementado en Cuentas. Esto se explica directamente en Perfil del comercio
- **Login/PIN/biometría propios del comercio** (`LoginComercio`, `PinLoginComercio`, `BiometriaComercio`, `DashboardComercio`) y **Registro de negocio** (`RegistroNegocio`) — no se construyeron: el prototipo los dibuja como una sesión paralela, pero la app ya usa una sola sesión para socio y comercio (ver pantalla de Login: "Identidad única CooPay — el mismo acceso para socio, comercio y supervisor"), y `Habilitar un nuevo comercio` ya cubre el alta de un negocio nuevo desde la sesión existente

## Estructura

```
lib/
├── main.dart
├── config/app_config.dart          # única fuente de variables de entorno
├── routing/route_observer.dart     # RouteObserver compartido — refresca Inicio/Cuentas/Detalle al volver de pagar o transferir
├── utils/idempotency.dart          # clave de idempotencia por intento de cobro/transferencia
├── theme/                          # colores y tipografía de marca
├── models/                         # misma forma que prisma/schema.prisma
├── repositories/                   # abstract + Mock... (y api_client.dart para el futuro Http...)
├── widgets/                        # BottomNavBar, AccountCard — compartidos entre pantallas
└── screens/
    ├── auth/           (Landing, Login, Registro)
    ├── inicio/
    ├── cuentas/         (lista, detalle, vincular cuenta + documentos)
    ├── comercios/        (lista, panel admin/supervisor, QR, historial, supervisores, perfil, sucursales, corte de caja)
    ├── perfil/
    ├── pagos/           (escanear QR, confirmar pago, transferir, comprobante)
    └── notificaciones/
```

## Cómo probar el frontend (tú o tu equipo)

Hay 3 formas, de más a menos trabajo. Para que el equipo lo pruebe sin instalar nada, usa la opción A.

### A) Link web compartible — Netlify Drop (recomendado, sin cuenta ni configuración)

1. Genera el build de producción:

   ```bash
   cd coopay_flutter
   flutter build web --release
   ```

   Esto deja todo listo en `coopay_flutter/build/web/`.
2. Abre [app.netlify.com/drop](https://app.netlify.com/drop) en el navegador.
3. Arrastra la carpeta `build/web` completa a la página.
4. En segundos te da una URL pública (algo como `https://nombre-al-azar.netlify.app`) — mándasela a tu equipo por WhatsApp/Slack/correo. Funciona en el celular y en la compu, no requiere instalar la app.
5. Si corriges algo y quieres actualizar el mismo link: vuelve a correr `flutter build web --release` y arrastra la carpeta de nuevo a la misma página de Netlify Drop (te da opción de reemplazar el sitio).

No requiere cuenta para la primera subida; si quieres un link permanente que no expire, te pide crear una cuenta gratis la primera vez que lo reclamas ("Claim this site").

### B) Link web permanente — Firebase Hosting (más control, requiere cuenta de Google)

Útil si quieres un dominio fijo que no cambie entre builds.

```bash
cd coopay_flutter
flutter build web --release
npm install -g firebase-tools
firebase login
firebase init hosting   # elige "build/web" como directorio público, SPA: Yes
firebase deploy
```

Te da una URL fija tipo `https://tu-proyecto.web.app` que puedes volver a desplegar (`firebase deploy`) cada vez que haya cambios.

### C) APK para probar en Android directo (sin navegador)

Si tu equipo quiere instalarla como app real en su celular Android:

```bash
cd coopay_flutter
flutter build apk --release
```

El archivo queda en `coopay_flutter/build/app/outputs/flutter-apk/app-release.apk`. Compártelo por Drive/WhatsApp; cada persona lo abre en su Android y acepta instalar desde "orígenes desconocidos" (Android lo pide automáticamente la primera vez). No sirve para iPhone sin cuenta de desarrollador de Apple — para iOS, la opción A (link web) es la más simple.

### Mientras pruebas, ten en cuenta

- Todo es datos de ejemplo en memoria (`useMockData = true` en `lib/config/app_config.dart`) — no hay backend real todavía, así que **recargar la página o cerrar la pestaña borra lo que hayas cambiado** (ventas, PIN, sucursales nuevas, etc. vuelven a su estado inicial).
- El inicio de sesión no valida contraseña real: cualquier correo con el flujo de Login entra. Para ver datos ya precargados (ventas, comercios, movimientos) usa `nicolas.ibarra@example.com`.
- La app es responsiva a tamaño de celular (390×844 aprox.) — en pantalla de escritorio se ve como una tarjeta angosta centrada, eso es esperado.

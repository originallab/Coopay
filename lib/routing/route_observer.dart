import 'package:flutter/material.dart';

/// Un solo RouteObserver compartido — lo usan las pantallas que necesitan
/// refrescar sus datos cuando vuelven a quedar visibles (p. ej. después de
/// pagar o transferir, para no mostrar saldo/movimientos desactualizados).
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

import 'dart:async';

import 'rfid_models.dart';
import 'rfid_transport.dart';

class RfidService {
  RfidService({
    required Map<RfidTransportKind, RfidTransport> transports,
    RfidTransportKind defaultTransport = RfidTransportKind.urovoDirect,
  }) : _transports = transports,
       _defaultTransport = defaultTransport;

  final Map<RfidTransportKind, RfidTransport> _transports;
  final RfidTransportKind _defaultTransport;

  RfidTransport? _activeTransport;

  Stream<RfidEvent> get events {
    final transport = _activeTransport ?? _transports[_defaultTransport];
    if (transport == null) {
      return const Stream<RfidEvent>.empty();
    }
    return transport.events;
  }

  RfidTransport requireTransport([RfidTransportKind? kind]) {
    final transport = _transports[kind ?? _defaultTransport];
    if (transport == null) {
      throw StateError(
        'No RFID transport registered for ${kind ?? _defaultTransport}.',
      );
    }
    return transport;
  }

  Future<RfidStatus> initialize([RfidTransportKind? kind]) {
    final transport = requireTransport(kind);
    _activeTransport = transport;
    return transport.initialize();
  }

  Future<RfidStatus> connect(RfidConnectionConfig config) {
    final transport = requireTransport(config.transport);
    _activeTransport = transport;
    return transport.connect(config);
  }

  Future<RfidStatus> disconnect() {
    final transport = _activeTransport ?? requireTransport();
    return transport.disconnect();
  }

  Future<void> startInventory([
    RfidInventoryConfig config = const RfidInventoryConfig(),
  ]) {
    final transport = _activeTransport ?? requireTransport();
    return transport.startInventory(config);
  }

  Future<void> stopInventory() {
    final transport = _activeTransport ?? requireTransport();
    return transport.stopInventory();
  }

  Future<int?> getOutputPower() {
    final transport = _activeTransport ?? requireTransport();
    return transport.getOutputPower();
  }

  Future<void> setOutputPower(int power) {
    final transport = _activeTransport ?? requireTransport();
    return transport.setOutputPower(power);
  }

  Future<String?> getModuleFirmware() {
    final transport = _activeTransport ?? requireTransport();
    return transport.getModuleFirmware();
  }

  Future<String?> refreshReaderFirmware() {
    final transport = _activeTransport ?? requireTransport();
    return transport.refreshReaderFirmware();
  }

  Future<RfidStatus> getCachedStatus() {
    final transport = _activeTransport ?? requireTransport();
    return transport.getCachedStatus();
  }
}

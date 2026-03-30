import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rfid_models.dart';
import 'rfid_transport.dart';

class UrovoDirectRfidTransport implements RfidTransport {
  UrovoDirectRfidTransport({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel(_methodChannelName),
       _eventChannel = eventChannel ?? const EventChannel(_eventChannelName);

  static const String _methodChannelName =
      'com.example.flutter_application_1/rfid/urovo_direct/methods';
  static const String _eventChannelName =
      'com.example.flutter_application_1/rfid/urovo_direct/events';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<RfidEvent>? _events;

  @override
  RfidTransportKind get kind => RfidTransportKind.urovoDirect;

  @override
  Stream<RfidEvent> get events {
    return _events ??= _eventChannel.receiveBroadcastStream().map((
      dynamic event,
    ) {
      final map = Map<Object?, Object?>.from(event as Map);
      return RfidEvent.fromMap(map);
    });
  }

  @override
  Future<bool> isSupported() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    return await _methodChannel.invokeMethod<bool>('isSupported') ?? false;
  }

  @override
  Future<RfidStatus> initialize() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'initialize',
    );
    return RfidStatus.fromMap(raw ?? const <Object?, Object?>{});
  }

  @override
  Future<RfidStatus> connect(RfidConnectionConfig config) async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'connect',
      config.toMap(),
    );
    return RfidStatus.fromMap(raw ?? const <Object?, Object?>{});
  }

  @override
  Future<RfidStatus> disconnect() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'disconnect',
    );
    return RfidStatus.fromMap(raw ?? const <Object?, Object?>{});
  }

  @override
  Future<void> startInventory([
    RfidInventoryConfig config = const RfidInventoryConfig(),
  ]) async {
    await _methodChannel.invokeMethod<void>('startInventory', config.toMap());
  }

  @override
  Future<void> stopInventory() async {
    await _methodChannel.invokeMethod<void>('stopInventory');
  }

  @override
  Future<int?> getOutputPower() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getOutputPower',
    );
    return (raw?['cachedPower'] as num?)?.toInt();
  }

  @override
  Future<void> setOutputPower(int power) {
    return _methodChannel.invokeMethod<void>(
      'setOutputPower',
      <String, Object?>{'power': power},
    );
  }

  @override
  Future<String?> getModuleFirmware() {
    return _methodChannel.invokeMethod<String>('getModuleFirmware');
  }

  @override
  Future<String?> refreshReaderFirmware() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'refreshReaderFirmware',
    );
    return raw?['cachedReaderFirmware'] as String?;
  }

  @override
  Future<RfidStatus> getCachedStatus() async {
    final raw = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getCachedStatus',
    );
    return RfidStatus.fromMap(raw ?? const <Object?, Object?>{});
  }
}

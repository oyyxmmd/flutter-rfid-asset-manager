import 'dart:async';

import 'package:flutter/foundation.dart';

import 'rfid.dart';

class ScannedTagView {
  const ScannedTagView({
    required this.epc,
    required this.rssi,
    required this.count,
    required this.readerId,
  });

  final String epc;
  final String rssi;
  final int count;
  final String readerId;

  ScannedTagView copyWith({String? rssi, int? count, String? readerId}) {
    return ScannedTagView(
      epc: epc,
      rssi: rssi ?? this.rssi,
      count: count ?? this.count,
      readerId: readerId ?? this.readerId,
    );
  }
}

class AppRfidRuntime {
  AppRfidRuntime._()
    : _service = RfidService(
        transports: <RfidTransportKind, RfidTransport>{
          RfidTransportKind.urovoDirect: UrovoDirectRfidTransport(),
        },
      ) {
    _eventSubscription = _service.events.listen(_handleEvent);
  }

  static final AppRfidRuntime instance = AppRfidRuntime._();

  final RfidService _service;
  late final StreamSubscription<RfidEvent> _eventSubscription;

  final ValueNotifier<RfidStatus> status = ValueNotifier<RfidStatus>(
    const RfidStatus(initialized: false, connected: false),
  );
  final ValueNotifier<List<ScannedTagView>> scannedTags =
      ValueNotifier<List<ScannedTagView>>(const <ScannedTagView>[]);
  final ValueNotifier<int> latestPower = ValueNotifier<int>(28);
  final ValueNotifier<String?> lastCommandText = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isScanning = ValueNotifier<bool>(false);
  final ValueNotifier<int> inventoryRate = ValueNotifier<int>(0);

  bool _bootstrapped = false;

  Future<void> ensureReady() async {
    if (_bootstrapped) {
      return;
    }
    _bootstrapped = true;
    final supported = await _service.requireTransport().isSupported();
    if (!supported) {
      lastCommandText.value = '当前平台不支持优博讯直连';
      return;
    }
    final currentStatus = await _service.initialize();
    status.value = currentStatus;
    if (currentStatus.outputPower != null) {
      latestPower.value = currentStatus.outputPower!;
    }
  }

  Future<void> connectDirect() async {
    await ensureReady();
    final nextStatus = await _service.connect(
      const RfidConnectionConfig(
        transport: RfidTransportKind.urovoDirect,
        port: '/dev/ttyHSL0',
        baudRate: 115200,
      ),
    );
    status.value = nextStatus;
    if (nextStatus.outputPower != null) {
      latestPower.value = nextStatus.outputPower!;
    }
  }

  Future<void> disconnect() async {
    final nextStatus = await _service.disconnect();
    status.value = nextStatus;
    isScanning.value = false;
  }

  Future<void> queryPower() async {
    await ensureReady();
    final power = await _service.getOutputPower();
    if (power != null) {
      latestPower.value = power;
    }
  }

  Future<void> savePower(int power) async {
    await _service.setOutputPower(power);
    latestPower.value = power;
  }

  Future<void> refreshReaderFirmware() async {
    await _service.refreshReaderFirmware();
  }

  Future<void> startInventory() async {
    scannedTags.value = const <ScannedTagView>[];
    inventoryRate.value = 0;
    await _service.startInventory();
    isScanning.value = true;
  }

  Future<void> stopInventory() async {
    await _service.stopInventory();
    isScanning.value = false;
  }

  void dispose() {
    _eventSubscription.cancel();
    status.dispose();
    scannedTags.dispose();
    latestPower.dispose();
    lastCommandText.dispose();
    isScanning.dispose();
    inventoryRate.dispose();
  }

  void _handleEvent(RfidEvent event) {
    if (event is RfidSettingsRefreshedEvent) {
      latestPower.value = event.power ?? latestPower.value;
      status.value = RfidStatus(
        initialized: status.value.initialized,
        connected: status.value.connected,
        moduleFirmware: status.value.moduleFirmware,
        readerFirmware: event.readerFirmware ?? status.value.readerFirmware,
        outputPower: event.power ?? status.value.outputPower,
        readId: event.readId ?? status.value.readId,
      );
      return;
    }
    if (event is RfidCommandStatusEvent) {
      final command = event.cmdName ?? 'Unknown';
      final state = event.statusName ?? '${event.status ?? ''}';
      lastCommandText.value = '$command: $state';
      return;
    }
    if (event is RfidInventoryTagEvent) {
      final current = <String, ScannedTagView>{
        for (final item in scannedTags.value) item.epc: item,
      };
      final previous = current[event.epc];
      current[event.epc] =
          (previous ??
                  ScannedTagView(
                    epc: event.epc,
                    rssi: event.rssi ?? '--',
                    count: 0,
                    readerId: event.readerId ?? '--',
                  ))
              .copyWith(
                rssi: event.rssi ?? previous?.rssi ?? '--',
                count: (previous?.count ?? 0) + 1,
                readerId: event.readerId ?? previous?.readerId ?? '--',
              );
      scannedTags.value = current.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return;
    }
    if (event is RfidInventoryEndEvent) {
      inventoryRate.value = event.readRate ?? inventoryRate.value;
      isScanning.value = false;
      return;
    }
    if (event is RfidRawEvent) {
      if (event.type == 'lifecycle') {
        final payload = event.payload;
        final lifecycleStatus = payload['status'] as String?;
        if (lifecycleStatus == 'connected') {
          status.value = RfidStatus(
            initialized: true,
            connected: true,
            moduleFirmware: payload['moduleFirmware'] as String?,
            readerFirmware: status.value.readerFirmware,
            outputPower: status.value.outputPower,
            readId: status.value.readId,
          );
        } else if (lifecycleStatus == 'disconnected') {
          status.value = RfidStatus(
            initialized: status.value.initialized,
            connected: false,
            moduleFirmware: status.value.moduleFirmware,
            readerFirmware: status.value.readerFirmware,
            outputPower: status.value.outputPower,
            readId: status.value.readId,
          );
        } else if (lifecycleStatus == 'initialized') {
          status.value = RfidStatus(
            initialized: true,
            connected: status.value.connected,
            moduleFirmware: status.value.moduleFirmware,
            readerFirmware: status.value.readerFirmware,
            outputPower: status.value.outputPower,
            readId: status.value.readId,
          );
        }
      }
    }
  }
}

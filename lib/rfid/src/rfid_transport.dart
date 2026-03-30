import 'rfid_models.dart';

abstract interface class RfidTransport {
  RfidTransportKind get kind;

  Stream<RfidEvent> get events;

  Future<bool> isSupported();

  Future<RfidStatus> initialize();

  Future<RfidStatus> connect(RfidConnectionConfig config);

  Future<RfidStatus> disconnect();

  Future<void> startInventory([
    RfidInventoryConfig config = const RfidInventoryConfig(),
  ]);

  Future<void> stopInventory();

  Future<int?> getOutputPower();

  Future<void> setOutputPower(int power);

  Future<String?> getModuleFirmware();

  Future<String?> refreshReaderFirmware();

  Future<RfidStatus> getCachedStatus();
}

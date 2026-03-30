enum RfidTransportKind { urovoDirect, bluetooth }

class RfidConnectionConfig {
  const RfidConnectionConfig({
    required this.transport,
    this.port,
    this.baudRate,
    this.deviceId,
  });

  final RfidTransportKind transport;
  final String? port;
  final int? baudRate;
  final String? deviceId;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'transport': transport.name,
      'port': port,
      'baudRate': baudRate,
      'deviceId': deviceId,
    };
  }
}

class RfidInventoryConfig {
  const RfidInventoryConfig({
    this.session = 1,
    this.target = 0,
    this.repeat = 1,
  });

  final int session;
  final int target;
  final int repeat;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'session': session,
      'target': target,
      'repeat': repeat,
    };
  }
}

class RfidStatus {
  const RfidStatus({
    required this.initialized,
    required this.connected,
    this.moduleFirmware,
    this.readerFirmware,
    this.outputPower,
    this.readId,
  });

  final bool initialized;
  final bool connected;
  final String? moduleFirmware;
  final String? readerFirmware;
  final int? outputPower;
  final int? readId;

  factory RfidStatus.fromMap(Map<Object?, Object?> map) {
    return RfidStatus(
      initialized: map['initialized'] == true,
      connected: map['connected'] == true,
      moduleFirmware: map['moduleFirmware'] as String?,
      readerFirmware: map['readerFirmware'] as String?,
      outputPower: (map['outputPower'] as num?)?.toInt(),
      readId: (map['readId'] as num?)?.toInt(),
    );
  }
}

sealed class RfidEvent {
  const RfidEvent(this.type);

  final String type;

  factory RfidEvent.fromMap(Map<Object?, Object?> map) {
    final type = map['type'] as String? ?? 'unknown';
    switch (type) {
      case 'inventoryTag':
        return RfidInventoryTagEvent.fromMap(map);
      case 'inventoryEnd':
        return RfidInventoryEndEvent.fromMap(map);
      case 'commandStatus':
        return RfidCommandStatusEvent.fromMap(map);
      case 'settingsRefreshed':
        return RfidSettingsRefreshedEvent.fromMap(map);
      default:
        return RfidRawEvent(type, Map<Object?, Object?>.from(map));
    }
  }
}

class RfidRawEvent extends RfidEvent {
  const RfidRawEvent(super.type, this.payload);

  final Map<Object?, Object?> payload;
}

class RfidInventoryTagEvent extends RfidEvent {
  const RfidInventoryTagEvent({
    required this.epc,
    this.pc,
    this.crc,
    this.ant,
    this.rssi,
    this.frequency,
    this.phase,
    this.count,
    this.readerId,
    this.cmd,
  }) : super('inventoryTag');

  final String epc;
  final String? pc;
  final String? crc;
  final int? ant;
  final String? rssi;
  final String? frequency;
  final int? phase;
  final int? count;
  final String? readerId;
  final int? cmd;

  factory RfidInventoryTagEvent.fromMap(Map<Object?, Object?> map) {
    return RfidInventoryTagEvent(
      epc: map['epc'] as String? ?? '',
      pc: map['pc'] as String?,
      crc: map['crc'] as String?,
      ant: (map['ant'] as num?)?.toInt(),
      rssi: map['rssi'] as String?,
      frequency: map['frequency'] as String?,
      phase: (map['phase'] as num?)?.toInt(),
      count: (map['count'] as num?)?.toInt(),
      readerId: map['readerId'] as String?,
      cmd: (map['cmd'] as num?)?.toInt(),
    );
  }
}

class RfidInventoryEndEvent extends RfidEvent {
  const RfidInventoryEndEvent({
    this.antennaId,
    this.inventoryCount,
    this.readRate,
    this.totalRead,
    this.cmd,
  }) : super('inventoryEnd');

  final int? antennaId;
  final int? inventoryCount;
  final int? readRate;
  final int? totalRead;
  final int? cmd;

  factory RfidInventoryEndEvent.fromMap(Map<Object?, Object?> map) {
    return RfidInventoryEndEvent(
      antennaId: (map['antennaId'] as num?)?.toInt(),
      inventoryCount: (map['inventoryCount'] as num?)?.toInt(),
      readRate: (map['readRate'] as num?)?.toInt(),
      totalRead: (map['totalRead'] as num?)?.toInt(),
      cmd: (map['cmd'] as num?)?.toInt(),
    );
  }
}

class RfidCommandStatusEvent extends RfidEvent {
  const RfidCommandStatusEvent({
    this.cmd,
    this.status,
    this.cmdName,
    this.statusName,
  }) : super('commandStatus');

  final int? cmd;
  final int? status;
  final String? cmdName;
  final String? statusName;

  factory RfidCommandStatusEvent.fromMap(Map<Object?, Object?> map) {
    return RfidCommandStatusEvent(
      cmd: (map['cmd'] as num?)?.toInt(),
      status: (map['status'] as num?)?.toInt(),
      cmdName: map['cmdName'] as String?,
      statusName: map['statusName'] as String?,
    );
  }
}

class RfidSettingsRefreshedEvent extends RfidEvent {
  const RfidSettingsRefreshedEvent({
    this.power,
    this.readerFirmware,
    this.readId,
  }) : super('settingsRefreshed');

  final int? power;
  final String? readerFirmware;
  final int? readId;

  factory RfidSettingsRefreshedEvent.fromMap(Map<Object?, Object?> map) {
    return RfidSettingsRefreshedEvent(
      power: (map['power'] as num?)?.toInt(),
      readerFirmware: map['readerFirmware'] as String?,
      readId: (map['readId'] as num?)?.toInt(),
    );
  }
}

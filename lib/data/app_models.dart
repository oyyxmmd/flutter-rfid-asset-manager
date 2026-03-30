class AssetItem {
  const AssetItem({
    required this.id,
    required this.name,
    required this.code,
    required this.rfid,
    required this.department,
    required this.category,
    required this.custodian,
    required this.location,
    required this.quantity,
    required this.unit,
    required this.receivedDate,
    required this.expiryYears,
    required this.usedYears,
    required this.note,
    required this.assetStatus,
    required this.inventoryStatus,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String code;
  final String rfid;
  final String department;
  final String category;
  final String custodian;
  final String location;
  final int quantity;
  final String unit;
  final DateTime receivedDate;
  final int expiryYears;
  final double usedYears;
  final String note;
  final String assetStatus;
  final String inventoryStatus;
  final bool isNew;

  AssetItem copyWith({
    String? name,
    String? code,
    String? rfid,
    String? department,
    String? category,
    String? custodian,
    String? location,
    int? quantity,
    String? unit,
    DateTime? receivedDate,
    int? expiryYears,
    double? usedYears,
    String? note,
    String? assetStatus,
    String? inventoryStatus,
    bool? isNew,
  }) {
    return AssetItem(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      rfid: rfid ?? this.rfid,
      department: department ?? this.department,
      category: category ?? this.category,
      custodian: custodian ?? this.custodian,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      receivedDate: receivedDate ?? this.receivedDate,
      expiryYears: expiryYears ?? this.expiryYears,
      usedYears: usedYears ?? this.usedYears,
      note: note ?? this.note,
      assetStatus: assetStatus ?? this.assetStatus,
      inventoryStatus: inventoryStatus ?? this.inventoryStatus,
      isNew: isNew ?? this.isNew,
    );
  }
}

class DepartmentItem {
  const DepartmentItem({
    this.id,
    required this.name,
    required this.manager,
    required this.assetCount,
    this.parent = '总部',
  });

  final int? id;
  final String name;
  final String manager;
  final int assetCount;
  final String parent;
}

class CategoryItem {
  const CategoryItem({
    this.id,
    required this.name,
    required this.parent,
    required this.assetCount,
  });

  final int? id;
  final String name;
  final String parent;
  final int assetCount;
}

class AppSnapshot {
  const AppSnapshot({
    required this.assets,
    required this.departments,
    required this.categories,
  });

  final List<AssetItem> assets;
  final List<DepartmentItem> departments;
  final List<CategoryItem> categories;
}

class AssetImportResult {
  const AssetImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;
}

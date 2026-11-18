class RoomModel {
  final String id;
  final String roomNumber;
  final String floor;
  final String status;
  final String roomType;
  final String hotelId;
  final String cleanStatus;
  final String updatedAt;
  final int version;

  // Task & Room info if merged
  final String? taskId;
  final String? taskStatus;
  final String? priority;
  final String? assignedTo;
  final String? assignedToName;
  final String? description;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    this.floor = '',
    this.status = 'AVAILABLE',
    this.roomType = 'Standard',
    this.hotelId = '',
    this.cleanStatus = 'CLEAN',
    this.updatedAt = '',
    this.version = 1,
    this.taskId,
    this.taskStatus,
    this.priority,
    this.assignedTo,
    this.assignedToName,
    this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: (json['id'] ?? json['_id'] ?? json['roomId'] ?? '').toString(),
      roomNumber: (json['roomNumber'] ?? json['number'] ?? json['name'] ?? '--').toString(),
      floor: (json['floor'] ?? json['roomFloor'] ?? '').toString(),
      status: (json['status'] ?? 'AVAILABLE').toString().toUpperCase(),
      roomType: (json['roomType'] ?? json['type'] ?? json['roomTypeName'] ?? 'Tiêu chuẩn').toString(),
      hotelId: (json['hotelId'] ?? '').toString(),
      cleanStatus: (json['cleanStatus'] ?? json['cleaningStatus'] ?? 'CLEAN').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      version: json['version'] is int ? json['version'] as int : int.tryParse(json['version']?.toString() ?? '') ?? 1,
      taskId: json['taskId']?.toString() ?? (json.containsKey('roomId') ? json['id']?.toString() : null),
      taskStatus: json['taskStatus']?.toString(),
      priority: (json['priority'] ?? 'NORMAL').toString().toUpperCase(),
      assignedTo: json['assignedTo']?.toString(),
      assignedToName: (json['assignedToName'] ?? json['assignedName'] ?? '').toString(),
      description: (json['description'] ?? json['note'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': id,
      'roomNumber': roomNumber,
      'floor': floor,
      'status': status,
      'roomType': roomType,
      'hotelId': hotelId,
      'cleanStatus': cleanStatus,
      'updatedAt': updatedAt,
      'version': version,
      if (taskId != null) 'taskId': taskId,
      if (taskStatus != null) 'taskStatus': taskStatus,
      if (priority != null) 'priority': priority,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (assignedToName != null) 'assignedToName': assignedToName,
      if (description != null) 'description': description,
    };
  }

  RoomModel copyWith({
    String? id,
    String? roomNumber,
    String? floor,
    String? status,
    String? roomType,
    String? hotelId,
    String? cleanStatus,
    String? updatedAt,
    int? version,
    String? taskId,
    String? taskStatus,
    String? priority,
    String? assignedTo,
    String? assignedToName,
    String? description,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      roomType: roomType ?? this.roomType,
      hotelId: hotelId ?? this.hotelId,
      cleanStatus: cleanStatus ?? this.cleanStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      taskId: taskId ?? this.taskId,
      taskStatus: taskStatus ?? this.taskStatus,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      description: description ?? this.description,
    );
  }
}

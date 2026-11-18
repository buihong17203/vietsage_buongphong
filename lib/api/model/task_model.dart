class TaskModel {
  final String id;
  final String roomId;
  final String roomNumber;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String assignedTo;
  final String assignedToName;
  final String createdAt;
  final String updatedAt;
  final int version;

  const TaskModel({
    required this.id,
    required this.roomId,
    this.roomNumber = '',
    this.title = '',
    this.description = '',
    this.status = 'PENDING',
    this.priority = 'NORMAL',
    this.assignedTo = '',
    this.assignedToName = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.version = 1,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      roomId: (json['roomId'] ?? '').toString(),
      roomNumber: (json['roomNumber'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? json['note'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      priority: (json['priority'] ?? 'NORMAL').toString().toUpperCase(),
      assignedTo: (json['assignedTo'] ?? '').toString(),
      assignedToName: (json['assignedToName'] ?? json['assignedName'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      version: json['version'] is int ? json['version'] as int : int.tryParse(json['version']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
    };
  }
}

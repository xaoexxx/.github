import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Addon Type definition
@JsonSerializable()
class AddonType {
  final String name;
  final String description;
  final List<String> provides;
  final String category;
  final String icon;

  AddonType({
    required this.name,
    required this.description,
    required this.provides,
    required this.category,
    required this.icon,
  });

  factory AddonType.fromJson(Map<String, dynamic> json) => _$AddonTypeFromJson(json);
  Map<String, dynamic> toJson() => _$AddonTypeToJson(this);
}

/// House Storage
@JsonSerializable()
class HouseStorage {
  final List<String> conversations;
  final List<String> events;
  final List<String> nodes;
  final List<String> logs;

  HouseStorage({
    this.conversations = const [],
    this.events = const [],
    this.nodes = const [],
    this.logs = const [],
  });

  factory HouseStorage.fromJson(Map<String, dynamic> json) => _$HouseStorageFromJson(json);
  Map<String, dynamic> toJson() => _$HouseStorageToJson(this);
}

/// House Stats
@JsonSerializable()
class HouseStats {
  final int totalRuns;
  final int totalMessages;
  final String lastActive;

  HouseStats({
    required this.totalRuns,
    required this.totalMessages,
    required this.lastActive,
  });

  factory HouseStats.fromJson(Map<String, dynamic> json) => _$HouseStatsFromJson(json);
  Map<String, dynamic> toJson() => _$HouseStatsToJson(this);
}

/// Visitor
@JsonSerializable()
class Visitor {
  final String visitor;
  final String visitedAt;

  Visitor({
    required this.visitor,
    required this.visitedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);
  Map<String, dynamic> toJson() => _$VisitorToJson(this);
}

/// House Model
@JsonSerializable()
class House {
  final String id;
  final String owner;
  final String name;
  final String createdAt;
  final HouseStorage storage;
  final List<String> addons;
  final HouseStats stats;
  final List<Visitor> visitors;

  House({
    required this.id,
    required this.owner,
    required this.name,
    required this.createdAt,
    required this.storage,
    required this.addons,
    required this.stats,
    required this.visitors,
  });

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);
  Map<String, dynamic> toJson() => _$HouseToJson(this);
}

/// Addon Model
@JsonSerializable()
class Addon {
  final String id;
  final String houseId;
  final String type;
  final String name;
  final String description;
  final String category;
  final List<String> provides;
  final String icon;
  final Map<String, dynamic> data;
  final Map<String, dynamic> config;
  final String builtAt;
  final bool active;

  Addon({
    required this.id,
    required this.houseId,
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    required this.provides,
    required this.icon,
    required this.data,
    required this.config,
    required this.builtAt,
    required this.active,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => _$AddonFromJson(json);
  Map<String, dynamic> toJson() => _$AddonToJson(this);
}

/// Neighborhood Model
@JsonSerializable()
class Neighborhood {
  final String name;
  final List<String> houses;
  final Map<String, List<String>> adjacency;

  Neighborhood({
    required this.name,
    required this.houses,
    required this.adjacency,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) => _$NeighborhoodFromJson(json);
  Map<String, dynamic> toJson() => _$NeighborhoodToJson(this);
}

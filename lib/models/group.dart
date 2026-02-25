import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class GroupModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String paymentType;

  @HiveField(3)
  double courtPrice;

  @HiveField(4)
  DateTime startTime;

  @HiveField(5)
  DateTime endTime;

  GroupModel({
    required this.id,
    required this.name,
    required this.paymentType,
    required this.courtPrice,
    required this.startTime,
    required this.endTime,
  });
}

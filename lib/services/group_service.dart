import 'package:hive/hive.dart';
import '../models/group.dart';

class GroupService {
  static const boxName = "groupsBox";

  Future<void> addGroup(GroupModel group) async {
    final box = await Hive.openBox<GroupModel>(boxName);
    await box.put(group.id, group);
  }

  Future<List<GroupModel>> getGroups() async {
    final box = await Hive.openBox<GroupModel>(boxName);
    return box.values.toList();
  }

  Future<void> deleteGroup(String id) async {
    final box = await Hive.openBox<GroupModel>(boxName);
    await box.delete(id);
  }
}

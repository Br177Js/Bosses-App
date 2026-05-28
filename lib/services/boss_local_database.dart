import 'package:hive_ce/hive.dart';
import 'boss_repository.dart';

class BossLocalDatabase {
  static Box get _box => Hive.box("bosses");
  static List<Boss> getBosses() {
    return _box.values.map((item) {
      return Boss.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static List<Boss> defeatedBosses() {
    return _box.values.map((item) {
      return Boss.fromMap(Map<String, dynamic>.from(item));
    })
        .where((item) => item.defeated)
        .toList();
  }

  static List<Boss> undefeatedBosses() {
    return _box.values.map((item) {
      return Boss.fromMap(Map<String, dynamic>.from(item));
    })
        .where((item) => !item.defeated)
        .toList();
  }

  static Future<void> saveBosses(List<Boss> bosses) async {
    await _box.clear();
    for (final boss in bosses) {
      await _box.put(boss.id, boss.toMap());
    }
  }

  static bool isEmpty() {
    return _box.isEmpty;
  }
}

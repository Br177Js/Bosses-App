import 'boss_api_service.dart';
import 'boss_local_database.dart';

class BossSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (!BossLocalDatabase.isEmpty()) {
      return;
    }
    final bosses = await BossApiService.fetchBosses();
    await BossLocalDatabase.saveBosses(bosses);
  }
}

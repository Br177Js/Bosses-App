import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../services/boss_card.dart';
import '../services/boss_repository.dart';
import '../services/boss_local_database.dart';
import '../services/boss_api_service.dart';
import '../services/boss_sync_service.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("bosses");
  runApp(MaterialApp(home: BossListScreen(),));
}

class BossListScreen extends StatefulWidget {
  const BossListScreen({super.key});
  @override
  State<BossListScreen> createState() => _BossListScreenState();
}

class _BossListScreenState extends State<BossListScreen> {
  @override
  Widget build(BuildContext context){
    throw UnimplementedError("Yet to be implemented");
  }
}

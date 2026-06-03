import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'services/boss_card.dart';
import 'services/boss_repository.dart';
import 'services/boss_local_database.dart';
import 'services/boss_sync_service.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("bosses");
  runApp(MaterialApp(home: MainScreen(),));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreen();
}

class BossListScreen extends StatefulWidget {
  final String currentFilter;
  const BossListScreen({super.key, required this.currentFilter});
  @override
  State<BossListScreen> createState() => _BossListScreenState();
}

class _MainScreen extends State<MainScreen> {
  String filter = "wszyscy";
  String selectedFilter = "wszyscy";
  bool pressedAll = true;
  bool pressedDefeated = false;
  bool pressedToBeDefeated = false;
  Key _listKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text(
        "Bossowie",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Pobierz ponownie bazę bossów",
            onPressed: () async {
              await BossLocalDatabase.deleteAllBosses();
              setState(() {
                _listKey = UniqueKey();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pomyślnie pobrabno bazę bossów"),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wszyscy";
                      pressedAll = true;
                      pressedDefeated = false;
                      pressedToBeDefeated = false;
                    });
                  },
                  child: Text(
                    "Wszyscy",
                    style: TextStyle(
                      color: pressedAll
                          ? Colors.yellowAccent
                          : Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "do pokonania";
                      pressedToBeDefeated = true;
                      pressedAll = false;
                      pressedDefeated = false;
                    });
                  },
                  child: Text(
                    "Do pokonania",
                    style: TextStyle(
                      color: pressedToBeDefeated
                          ? Colors.yellowAccent
                          : Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "pokonani";
                      pressedDefeated = true;
                      pressedAll = false;
                      pressedToBeDefeated = false;
                    });
                  },
                  child: Text(
                    "Pokonani",
                    style: TextStyle(
                      color: pressedDefeated
                          ? Colors.yellowAccent
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BossListScreen(
                key: _listKey,
                currentFilter: selectedFilter,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BossListScreenState extends State<BossListScreen> {
  late Future<List<Boss>> bossesFuture;
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    bossesFuture = loadBosses();
  }

  Future<List<Boss>> loadBosses() async {
    await BossSyncService.loadInitialDataIfNeeded();
    return BossLocalDatabase.getBosses();
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future: bossesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "Wystąpił błąd: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          bossesFuture = loadBosses();
                        });
                      },
                      child: const Text("Spróbuj ponownie"))
                ],
              ),
            );
          }

          List<Boss> filteredBosses = BossLocalDatabase.getBosses();
          if (widget.currentFilter == "pokonani") {
            filteredBosses = BossLocalDatabase.defeatedBosses();
          } else if (widget.currentFilter == "do pokonania") {
            filteredBosses = BossLocalDatabase.undefeatedBosses();
          }

          if (filteredBosses.isEmpty) {
            return const Center(child: Text("Brak bossów należących do tej kategorii", style: TextStyle(color: Colors.yellow),));
          }

          return ListView.builder(
            itemCount: filteredBosses.length,
            itemBuilder: (context, index) {
              final boss = filteredBosses[index];
              return Dismissible(
                key: ValueKey(boss.id),
                child: BossCard(
                  id: boss.id,
                  name: boss.name,
                  location: "Lokalizacja: ${boss.location}",
                  defeated: boss.defeated,
                  onChanged: (value) async {
                    final updatedBoss = Boss(
                      id: boss.id,
                      name: boss.name,
                      image: boss.image,
                      description: boss.description,
                      location: boss.location,
                      drops: boss.drops,
                      defeated: value ?? false,
                    );
                    await BossLocalDatabase.updateBoss(updatedBoss);
                    setState(() {});
                  },
                  onTap: () async {
                    final Boss? value = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => BossDetailScreen(boss: boss,),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        }
                      )
                    );
                  },
                ),
              );
            },
          );
        }
    );
  }
}

class BossDetailScreen extends StatelessWidget {
  final Boss boss;
  BossDetailScreen({super.key, required this.boss});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text(
          boss.name,
          style: TextStyle(
            fontSize: 30,
            color: Colors.yellowAccent,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            boss.image != null && boss.image!.isNotEmpty
                ? Image.network(boss.image!)
                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Opis: ${boss.description}",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Lokalizacja: ${boss.location}",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Pozostawia:",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 20,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: boss.drops.length,
                itemBuilder: (context, index) {
                  final item = boss.drops[index];
                  return ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                          color: Colors.yellowAccent
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BossCard extends StatelessWidget {
  final String id;
  final String name;
  final String location;
  final bool defeated;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;
  const BossCard({
    super.key,
    required this.id,
    required this.name,
    required this.location,
    required this.defeated,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
            value: defeated,
            onChanged: onChanged
        ),
        title: Text(
          name,
          style: TextStyle(
            decoration: defeated
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: defeated
                ? Colors.grey
                : Colors.yellowAccent
          ),
        ),
        subtitle: Text(
          location,
          style: TextStyle(
              color: defeated
                  ? Colors.grey
                  : Colors.yellowAccent
          ),
        ),
        trailing: Icon(Icons.density_medium_sharp),
      ),
    );
  }
}

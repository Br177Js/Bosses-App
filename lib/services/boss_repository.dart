
class Boss {
  final int id;
  final String name;
  final String image;
  final String description;
  final String location;
  final List<String> drops;
  bool defeated;
  Boss({required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.location,
    required this.drops,
    required this.defeated});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "description": description,
      "location": location,
      "drops": drops,
      "defeated": defeated,
    };
  }

  factory Boss.fromMap(Map map) {
    return Boss(
      id: map["id"],
      name: map["name"],
      image: map["image"],
      description: map["description"],
      location: map["location"],
      drops: map["drops"],
      defeated: map["defeated"],
    );
  }
}

class VoteChoice {
  final String id;
  int voteCount;
  String name;
  String description;

  VoteChoice({
    required this.id,
    this.voteCount = 0,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voteCount': voteCount,
      'name': name,
      'description': description,
    };
  }

  factory VoteChoice.fromMap(Map<String, dynamic> map) {
    return VoteChoice(
      id: map['id'],
      voteCount: map['voteCount'],
      name: map['name'],
      description: map['description'],
    );
  }

  VoteChoice copyWith({
    String? id,
    int? voteCount,
    String? name,
    String? description,
  }) {
    return VoteChoice(
      id: id ?? this.id,
      voteCount: voteCount ?? this.voteCount,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'VoteChoice{id: $id, voteCount: $voteCount, name: $name, description: $description}';
  }
}
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
  factory VoteChoice.fromJson(Map<String, dynamic> map) {
    return VoteChoice(
      id: map['ID'],
      voteCount: map['Score'],
      name: map['Name'],
      description: map['Description'],
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
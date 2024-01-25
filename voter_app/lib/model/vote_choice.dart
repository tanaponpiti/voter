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

class VoteChoiceEdit {
  final String id;
  String? name;
  String? description;

  VoteChoiceEdit({
    required this.id,
    this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory VoteChoiceEdit.fromJson(Map<String, dynamic> map) {
    return VoteChoiceEdit(
      id: map['ID'],
      name: map['Name'],
      description: map['Description'],
    );
  }

  VoteChoiceEdit copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return VoteChoiceEdit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'VoteChoiceEdit{id: $id, name: $name, description: $description}';
  }
}

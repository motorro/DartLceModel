class Repository {
  final String name;
  final String language;

  const Repository(this.name, this.language);

  factory Repository.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final language = json['language'];
    return Repository(
      name is String ? name : 'Unknown name',
      language is String ? language : 'Unknown language'
    );
  }
}
class GameModel {
  final int id;
  final String name;
  final String? backgroundImage;
  final double rating;
  double progress;

  GameModel({
    required this.id,
    required this.name,
    this.backgroundImage,
    required this.rating,
    required this.progress,
  });

  factory GameModel.fromMap(Map<String, dynamic> map, {double progress = 0.0}) {
    return GameModel(
      id: map['id'],
      name: map['name'],
      backgroundImage: map['background_image'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      progress: progress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'background_image': backgroundImage,
      'rating': rating,
      'progress': progress,
    };
  }
}

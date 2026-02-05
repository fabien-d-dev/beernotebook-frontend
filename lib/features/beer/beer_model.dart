class Beer {
  final String id;
  final String name;
  final String brewery;
  final String type; 
  final double rating;

  Beer({
    required this.id,
    required this.name,
    required this.brewery,
    this.type = "Générique",
    required this.rating,
  });
}

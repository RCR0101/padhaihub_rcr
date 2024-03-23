class User {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.imageUrl});

  // Constructor that creates a User instance from a Firestore document.
  factory User.fromFirestore(Map<String, dynamic> doc) {
    return User(
      id: doc['id'] as String,
      name: doc['name'] as String,
      email: doc['email'] as String,
      imageUrl: doc['imageUrl'] as String,
    );
  }

  // Method to convert User instance to a map, useful for saving data to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
    };
  }
}

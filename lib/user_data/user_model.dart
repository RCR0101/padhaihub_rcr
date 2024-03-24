class User_D {
  final String id;
  final String name;
  final String email;
  final String imageUrl;

  User_D(
      {required this.id,
      required this.name,
      required this.email,
      required this.imageUrl});

  // Constructor that creates a User instance from a Firestore document.
  factory User_D.fromFirestore(Map<String, dynamic> doc) {
    return User_D(
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

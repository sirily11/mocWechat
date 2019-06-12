class Friend {
  final String userId;
  final String userName;
  final String dateOfBirth;
  final String sex;
  final String description;
  final List<dynamic> friends;

//  Friend(this.userName, this.sex, this.dateOfBirth, this.userId);
  Friend(
      {this.userId,
      this.userName,
      this.dateOfBirth,
      this.sex,
      this.description,
      this.friends});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
        userId: json['_id'],
        userName: json['userName'],
        dateOfBirth: json['dateOfBirth'],
        sex: json['sex'],
        description: json['description'],
        friends: json['friends']);
  }
}

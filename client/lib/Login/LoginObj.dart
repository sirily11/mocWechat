class SignUpObj{
  final String err;
  final String userId;

  SignUpObj({this.err, this.userId});

  factory SignUpObj.fromJson(Map<String, dynamic> json){
    return SignUpObj(err: json['err'], userId: json['userId']);
  }
}
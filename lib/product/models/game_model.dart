class GameModel {
  String id;
  String name;
  int personFee;
  int personFeeDouble;
  int videoFee;
  List<dynamic> hours;

  GameModel({
    required this.id,
    required this.name,
    required this.personFee,
    required this.personFeeDouble,
    required this.videoFee,
    required this.hours,
  });

  GameModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        personFee = json['personFee'],
        personFeeDouble = json['personFeeDouble'],
        videoFee = json['videoFee'],
        hours = json['hours'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'personFee': personFee,
        'personFeeDouble': personFeeDouble,
        'videoFee': videoFee,
        'hours': hours,
      };

  @override
  String toString() => toJson().toString();
}

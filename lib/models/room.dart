import 'dart:math';

class Room {
  final String code;
  final String name;
  final String admin;
  final List<dynamic> members;

  Room.from({
    required this.code,
    required this.name,
    required this.admin,
    this.members = const [],
  });

  static Room createRoom({
    required String name,
    required String admin,
  }) {
    String charSet = DateTime.now().toString() + name + admin;
    charSet = charSet.replaceAll(RegExp(r'[^\w]+'), '');
    Random ram = Random();
    var code = String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => charSet.codeUnitAt(ram.nextInt(charSet.length)),
      ),
    );
    return Room.from(code: code, name: name, admin: admin);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Room && code == other.code;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin': admin,
      'people': members,
      'code': code,
    };
  }

  static Room fromJson(Map data) {
    return Room.from(
      name: data['name'],
      admin: data['admin'],
      members: data['people'],
      code: data['code'],
    );
  }
}

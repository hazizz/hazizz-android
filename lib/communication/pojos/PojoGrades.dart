<<<<<<< HEAD
import 'package:mobile/communication/pojos/PojoGrade.dart';
=======
import 'package:hazizz_mobile/communication/pojos/PojoGrade.dart';
>>>>>>> 4c9d004c5a9e9c416ab5b26080cdb3e8a330b7fc
import 'package:json_annotation/json_annotation.dart';

import 'Pojo.dart';

part 'PojoGrades.g.dart';

@JsonSerializable()
class PojoGrades extends Pojo{

  // final Map<String, List<PojoClass>> classes;

  final Map<String, List<PojoGrade>> grades;

  PojoGrades(this.grades);

  factory PojoGrades.fromJson(Map<String, dynamic> json) =>
      _$PojoGradesFromJson(json);
}
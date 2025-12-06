import 'package:equatable/equatable.dart';

abstract class IdPair with EquatableMixin {
  dynamic get idType;
  String get idCode; // right now always strings
  bool get isValid;
  String get displayName;
  IdPair copyWith({dynamic idType, String? idCode});
}

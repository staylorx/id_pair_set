/// Names an id type the way it is stored: an enum by value name, else as text.
///
/// One definition, used by `IdPairSet.toJson` and by anything that keys ids by
/// type, so a stored key and a looked-up key cannot drift apart.
String idTypeKey({required Object idType}) =>
    idType is Enum ? idType.name : '$idType';

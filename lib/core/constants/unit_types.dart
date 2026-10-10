enum UnitType {
  piece,
  packet,
  box,
  kg,
  gram,
  litre,
  millilitre,
  dozen,
}

extension UnitTypeX on UnitType {
  String get label {
    switch (this) {
      case UnitType.piece:
        return 'Piece';
      case UnitType.packet:
        return 'Packet';
      case UnitType.box:
        return 'Box';
      case UnitType.kg:
        return 'Kg';
      case UnitType.gram:
        return 'Gram';
      case UnitType.litre:
        return 'Litre';
      case UnitType.millilitre:
        return 'Millilitre';
      case UnitType.dozen:
        return 'Dozen';
    }
  }

  static UnitType fromString(String value) {
    return UnitType.values.firstWhere(
      (u) => u.name == value.toLowerCase(),
      orElse: () => UnitType.piece,
    );
  }
}

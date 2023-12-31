import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenify/model/plant_model.dart';

class PotModel {
  String? id;
  late PotStatus status;
  final int positionIndex;
  String? createdAt;
  String? updatedAt;
  final PlantModel plant;
  static const String collectionPath = 'pots';

  DocumentReference? ref;

  DateTime? get createdAtDate =>
      createdAt != null ? DateTime.parse(createdAt!) : null;
  DateTime? get updatedAtDate =>
      updatedAt != null ? DateTime.parse(updatedAt!) : null;

  PotModel(
      {required this.status,
      required this.positionIndex,
      required this.plant,
      this.createdAt,
      this.updatedAt,
      this.id});

  PotModel.fromQuery(DocumentSnapshot<Object?> element)
      : id = element.id,
        positionIndex = element['position_index'],
        plant = PlantModel.fromQuery(element['plant']),
        createdAt = element['created_at'].toString(),
        updatedAt = element['updated_at'].toString() {
    ref = element.reference;
    status = reverseStatusParse(element['status']);
  }

  PotStatus reverseStatusParse(String status) {
    switch (status) {
      case "empty":
        return PotStatus.empty;
      case "locked":
        return PotStatus.locked;
      case "filled":
        return PotStatus.filled;
      default:
        return PotStatus.empty;
    }
  }

  String statusParse(PotStatus status) {
    switch (status) {
      case PotStatus.empty:
        return "empty";
      case PotStatus.locked:
        return "locked";
      case PotStatus.filled:
        return "filled";
      default:
        return "empty";
    }
  }

  Map<String, dynamic> toQuery() {
    return {
      "status": statusParse(status),
      "position_index": positionIndex,
      "plant": plant.toQuery(),
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

enum PotStatus { empty, locked, filled }

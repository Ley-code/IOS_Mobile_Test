import 'package:equatable/equatable.dart';

class ContractEntity extends Equatable {
  final String contractId;
  final String offerId;
  final String clientId;
  final String freelancerId;
  final String? clientName;
  final String? freelancerName;
  final DateTime? startTime;
  final DateTime? endTime;
  final String contractTerms;
  final List<String> payoutTypes;
  final Map<String, double> payoutRates;
  final String status; // 'active', 'completed', 'pending', 'cancelled'
  final DateTime createdAt;
  final List<ContractDeliverableEntity> deliverables;

  const ContractEntity({
    required this.contractId,
    required this.offerId,
    required this.clientId,
    required this.freelancerId,
    this.clientName,
    this.freelancerName,
    this.startTime,
    this.endTime,
    required this.contractTerms,
    required this.payoutTypes,
    required this.payoutRates,
    required this.status,
    required this.createdAt,
    required this.deliverables,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        contractId,
        offerId,
        clientId,
        freelancerId,
        clientName,
        freelancerName,
        startTime,
        endTime,
        contractTerms,
        payoutTypes,
        payoutRates,
        status,
        createdAt,
        deliverables,
      ];
}

class ContractDeliverableEntity extends Equatable {
  final String deliverableId;
  final String contractId;
  final String deliverableType;
  final int quantity;
  final double? pricePerUnit;
  final String? description;
  final int completedCount;
  final int totalCount;

  const ContractDeliverableEntity({
    required this.deliverableId,
    required this.contractId,
    required this.deliverableType,
    required this.quantity,
    this.pricePerUnit,
    this.description,
    required this.completedCount,
    required this.totalCount,
  });

  bool get isCompleted => completedCount >= totalCount;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  @override
  List<Object?> get props => [
        deliverableId,
        contractId,
        deliverableType,
        quantity,
        pricePerUnit,
        description,
        completedCount,
        totalCount,
      ];
}






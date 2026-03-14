import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';

class ContractModel extends ContractEntity {
  const ContractModel({
    required super.contractId,
    required super.offerId,
    required super.clientId,
    required super.freelancerId,
    super.clientName,
    super.freelancerName,
    super.startTime,
    super.endTime,
    required super.contractTerms,
    required super.payoutTypes,
    required super.payoutRates,
    required super.status,
    required super.createdAt,
    required super.deliverables,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    // Parse deliverables
    final deliverablesJson = json['deliverables'] as List? ?? [];
    final deliverables = deliverablesJson
        .map((e) => ContractDeliverableModel.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<ContractDeliverableEntity>();

    // Parse payout types
    final payoutTypesJson = json['payout_types'];
    final payoutTypes = payoutTypesJson is List
        ? (payoutTypesJson).map((e) => e.toString()).toList()
        : <String>[];

    // Parse payout rates
    final payoutRatesJson = json['payout_rates'] ?? {};
    final payoutRates = <String, double>{};
    if (payoutRatesJson is Map) {
      payoutRatesJson.forEach((key, value) {
        if (value is num) {
          payoutRates[key.toString()] = value.toDouble();
        }
      });
    }

    // Parse dates
    DateTime? parseDate(dynamic dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr.toString());
      } catch (e) {
        return null;
      }
    }

    // Get client/freelancer names from nested objects
    final client = json['client'] as Map<String, dynamic>?;
    final freelancer = json['freelancer'] as Map<String, dynamic>?;
    final clientName = client != null
        ? '${client['first_name'] ?? ''} ${client['last_name'] ?? ''}'.trim()
        : null;
    final freelancerName = freelancer != null
        ? '${freelancer['first_name'] ?? ''} ${freelancer['last_name'] ?? ''}'.trim()
        : null;

    return ContractModel(
      contractId: json['contract_id']?.toString() ?? '',
      offerId: json['offer_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? json['client_uuid']?.toString() ?? '',
      freelancerId: json['freelancer_id']?.toString() ?? json['freelancer_uuid']?.toString() ?? '',
      clientName: clientName,
      freelancerName: freelancerName,
      startTime: parseDate(json['start_time']),
      endTime: parseDate(json['end_time']),
      contractTerms: json['contract_terms']?.toString() ?? '',
      payoutTypes: payoutTypes,
      payoutRates: payoutRates,
      status: json['status']?.toString() ?? 'pending',
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      deliverables: deliverables,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract_id': contractId,
      'offer_id': offerId,
      'client_id': clientId,
      'freelancer_id': freelancerId,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'contract_terms': contractTerms,
      'payout_types': payoutTypes,
      'payout_rates': payoutRates,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'deliverables': deliverables.map((e) {
        if (e is ContractDeliverableModel) {
          return e.toJson();
        }
        return {};
      }).toList(),
    };
  }
}

class ContractDeliverableModel extends ContractDeliverableEntity {
  const ContractDeliverableModel({
    required super.deliverableId,
    required super.contractId,
    required super.deliverableType,
    required super.quantity,
    super.pricePerUnit,
    super.description,
    required super.completedCount,
    required super.totalCount,
  });

  factory ContractDeliverableModel.fromJson(Map<String, dynamic> json) {
    return ContractDeliverableModel(
      deliverableId: json['deliverable_id']?.toString() ?? '',
      contractId: json['contract_id']?.toString() ?? '',
      deliverableType: json['deliverable_type']?.toString() ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : (json['quantity'] as num?)?.toInt() ?? 0,
      pricePerUnit: json['price_per_unit'] is num ? (json['price_per_unit'] as num).toDouble() : null,
      description: json['description']?.toString(),
      completedCount: json['completed_count'] is int ? json['completed_count'] : (json['completed_count'] as num?)?.toInt() ?? 0,
      totalCount: json['total_count'] is int 
          ? json['total_count'] 
          : (json['total_count'] as num?)?.toInt() ?? 
            (json['quantity'] is int ? json['quantity'] : (json['quantity'] as num?)?.toInt() ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliverable_id': deliverableId,
      'contract_id': contractId,
      'deliverable_type': deliverableType,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'description': description,
      'completed_count': completedCount,
      'total_count': totalCount,
    };
  }
}


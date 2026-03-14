import 'package:equatable/equatable.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object> get props => [];
}

class LoadMyContracts extends ContractEvent {
  final bool activeOnly;

  const LoadMyContracts({this.activeOnly = false});

  @override
  List<Object> get props => [activeOnly];
}

class LoadContractById extends ContractEvent {
  final String contractId;

  const LoadContractById(this.contractId);

  @override
  List<Object> get props => [contractId];
}

class RefreshContracts extends ContractEvent {
  final bool activeOnly;

  const RefreshContracts({this.activeOnly = false});

  @override
  List<Object> get props => [activeOnly];
}










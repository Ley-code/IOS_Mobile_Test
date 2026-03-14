import 'package:equatable/equatable.dart';
import 'package:mobile_app/features/content_creator/projects/domain/entities/contract_entity.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {}

class ContractsLoaded extends ContractState {
  final List<ContractEntity> contracts;

  const ContractsLoaded(this.contracts);

  @override
  List<Object?> get props => [contracts];
}

class ContractLoaded extends ContractState {
  final ContractEntity contract;

  const ContractLoaded(this.contract);

  @override
  List<Object?> get props => [contract];
}

class ContractError extends ContractState {
  final String message;

  const ContractError(this.message);

  @override
  List<Object?> get props => [message];
}






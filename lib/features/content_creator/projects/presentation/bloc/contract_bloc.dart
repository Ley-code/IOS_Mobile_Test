import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/features/content_creator/projects/domain/usecases/get_contract_by_id.dart';
import 'package:mobile_app/features/content_creator/projects/domain/usecases/get_my_contracts.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_event.dart';
import 'package:mobile_app/features/content_creator/projects/presentation/bloc/contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final GetMyContracts getMyContracts;
  final GetContractById getContractById;

  ContractBloc({
    required this.getMyContracts,
    required this.getContractById,
  }) : super(ContractInitial()) {
    on<LoadMyContracts>(_onLoadMyContracts);
    on<LoadContractById>(_onLoadContractById);
    on<RefreshContracts>(_onRefreshContracts);
  }

  Future<void> _onLoadMyContracts(
    LoadMyContracts event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    final result = await getMyContracts(
      GetMyContractsParams(activeOnly: event.activeOnly),
    );
    result.fold(
      (failure) => emit(ContractError(failure.message)),
      (contracts) => emit(ContractsLoaded(contracts)),
    );
  }

  Future<void> _onLoadContractById(
    LoadContractById event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    final result = await getContractById(event.contractId);
    result.fold(
      (failure) => emit(ContractError(failure.message)),
      (contract) => emit(ContractLoaded(contract)),
    );
  }

  Future<void> _onRefreshContracts(
    RefreshContracts event,
    Emitter<ContractState> emit,
  ) async {
    // Keep current state if loaded, or show loading
    if (state is ContractsLoaded) {
      // Keep showing current contracts while refreshing
    } else {
      emit(ContractLoading());
    }

    final result = await getMyContracts(
      GetMyContractsParams(activeOnly: event.activeOnly),
    );
    result.fold(
      (failure) => emit(ContractError(failure.message)),
      (contracts) => emit(ContractsLoaded(contracts)),
    );
  }
}










import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/simulation_result.dart';
import '../services/simulation_service.dart';

// ---------- Events ----------
abstract class SimulationEvent extends Equatable {
  const SimulationEvent();
  @override
  List<Object> get props => [];
}

class RunSimulation extends SimulationEvent {
  final String mode;
  final List<String> instructions;
  final Map<String, dynamic> config;

  const RunSimulation({
    required this.mode,
    required this.instructions,
    required this.config,
  });

  @override
  List<Object> get props => [mode, instructions, config];
}

// ---------- States ----------
abstract class SimulationState extends Equatable {
  const SimulationState();
  @override
  List<Object> get props => [];
}

class SimulationInitial extends SimulationState {}

class SimulationLoading extends SimulationState {}

class SimulationLoaded extends SimulationState {
  final SimulationResult result;

  const SimulationLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class SimulationError extends SimulationState {
  final String message;

  const SimulationError(this.message);

  @override
  List<Object> get props => [message];
}

// ---------- BLoC ----------
class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final SimulationService service;

  SimulationBloc({required this.service}) : super(SimulationInitial()) {
    on<RunSimulation>((event, emit) async {
      emit(SimulationLoading());
      try {
        final result = await service.runSimulation(
          mode: event.mode,
          instructions: event.instructions,
          config: event.config,
        );
        emit(SimulationLoaded(result));
      } catch (e) {
        emit(SimulationError(e.toString()));
      }
    });
  }
}
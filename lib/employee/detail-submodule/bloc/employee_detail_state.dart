part of 'employee_detail_bloc.dart';

@immutable
sealed class EmployeeDetailState {}

final class EmployeeDetailStateLoading extends EmployeeDetailState {}

final class EmployeeDetailStateLoaded extends EmployeeDetailState {
  final EmployeeModel employeeDetail;
  final bool isFromCache;

  EmployeeDetailStateLoaded({
    required this.employeeDetail,
    this.isFromCache = false,
  });
}

final class EmployeeDetailStateError extends EmployeeDetailState {
  final String message;

  EmployeeDetailStateError({required this.message});
}

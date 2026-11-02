part of 'employee_listing_bloc.dart';

@immutable
sealed class EmployeeListingState {}

final class EmployeeListingStateLoading extends EmployeeListingState {}

final class EmployeeListingStateLoaded extends EmployeeListingState {
  final List<EmployeeModel> employees;
  final bool isFromCache;

  EmployeeListingStateLoaded({
    required this.employees,
    this.isFromCache = false,
  });
}

final class EmployeeListingStateError extends EmployeeListingState {
  final String message;

  EmployeeListingStateError({required this.message});
}

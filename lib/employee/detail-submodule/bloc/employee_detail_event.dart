part of 'employee_detail_bloc.dart';

@immutable
sealed class EmployeeDetailEvent {}

class FetchEmployeeDetailEvent extends EmployeeDetailEvent {
  final int employeeId;

  FetchEmployeeDetailEvent({required this.employeeId});
}
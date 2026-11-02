part of 'employee_listing_bloc.dart';

@immutable
sealed class EmployeeListingEvent {
  const EmployeeListingEvent();
}

class FetchEmployeeListingEvent extends EmployeeListingEvent {
  const FetchEmployeeListingEvent();
}

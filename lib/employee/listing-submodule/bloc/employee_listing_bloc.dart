import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';

part 'employee_listing_event.dart';
part 'employee_listing_state.dart';

class EmployeeListingBloc
    extends Bloc<EmployeeListingEvent, EmployeeListingState> {
  final Dio dio;
  final HiveOfflineService employeeCache;

    EmployeeListingBloc({required this.dio, required this.employeeCache})
      : super(EmployeeListingStateLoading()) {
      on<FetchEmployeeListingEvent>(
        _onFetchEmployeeListing,
        transformer: (events, mapper) => events.asyncExpand(mapper),
      );
  }

  Future<void> _onFetchEmployeeListing(
    FetchEmployeeListingEvent event,
    Emitter<EmployeeListingState> emit,
  ) async {
    emit(EmployeeListingStateLoading());
    try {
      final apiResult = await dio.get<dynamic>(
        'https://jsonplaceholder.typicode.com/users',
      );
      final data = apiResult.data;
      if (data is! List) {
        emit(
          EmployeeListingStateError(
            message: 'The employee list response was invalid.',
          ),
        );
        return;
      }

      final employees = data
          .map(
            (employee) => EmployeeModel.fromMap(
              Map<String, dynamic>.from(employee as Map),
            ),
          )
          .toList();
      await employeeCache.saveEmployees(employees);
      emit(EmployeeListingStateLoaded(employees: employees));
    } on DioException {
      try {
        final cachedEmployees = employeeCache.fetchEmployeeList();
        if (cachedEmployees != null) {
          emit(
            EmployeeListingStateLoaded(
              employees: cachedEmployees,
              isFromCache: true,
            ),
          );
        } else {
          emit(
            EmployeeListingStateError(
              message:
                  'Unable to load employees. Connect to the internet to load them for the first time.',
            ),
          );
        }
      } on FormatException {
        emit(
          EmployeeListingStateError(
            message: 'The saved employee data is invalid. Refresh to try again.',
          ),
        );
      } on TypeError {
        emit(
          EmployeeListingStateError(
            message: 'The saved employee data is invalid. Refresh to try again.',
          ),
        );
      }
    } on TypeError {
      emit(
        EmployeeListingStateError(
          message: 'The employee list response was invalid.',
        ),
      );
    } on FormatException {
      emit(
        EmployeeListingStateError(
          message: 'The employee list response was invalid.',
        ),
      );
    }
  }
}

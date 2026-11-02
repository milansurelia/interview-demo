import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';

part 'employee_detail_event.dart';
part 'employee_detail_state.dart';

class EmployeeDetailBloc
    extends Bloc<EmployeeDetailEvent, EmployeeDetailState> {
  final Dio dio;
  final HiveOfflineService employeeCache;

  EmployeeDetailBloc({required this.dio, required this.employeeCache})
    : super(EmployeeDetailStateLoading()) {
    on<FetchEmployeeDetailEvent>(
      _onFetchEmployeeDetail,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  Future<void> _onFetchEmployeeDetail(
    FetchEmployeeDetailEvent event,
    Emitter<EmployeeDetailState> emit,
  ) async {
    emit(EmployeeDetailStateLoading());
    try {
      final apiResult = await dio.get<dynamic>(
        'https://jsonplaceholder.typicode.com/users/${event.employeeId}',
      );
      final data = apiResult.data;
      if (data is! Map) {
        emit(
          EmployeeDetailStateError(
            message: 'The employee details response was invalid.',
          ),
        );
        return;
      }

      final employee = EmployeeModel.fromMap(Map<String, dynamic>.from(data));
      await employeeCache.saveEmployee(employee);
      emit(EmployeeDetailStateLoaded(employeeDetail: employee));
    } on DioException {
      try {
        final cachedEmployee = employeeCache.fetchEmployee(event.employeeId);
        if (cachedEmployee != null) {
          emit(
            EmployeeDetailStateLoaded(
              employeeDetail: cachedEmployee,
              isFromCache: true,
            ),
          );
        } else {
          emit(
            EmployeeDetailStateError(
              message: 'Unable to load employee details. Connect to the internet to load them for the first time.',
            ),
          );
        }
      } on TypeError {
        emit(
          EmployeeDetailStateError(
            message:
                'The saved employee data is invalid. Refresh to try again.',
          ),
        );
      } on FormatException {
        emit(
          EmployeeDetailStateError(
            message:
                'The saved employee data is invalid. Refresh to try again.',
          ),
        );
      }
    } on TypeError {
      emit(
        EmployeeDetailStateError(
          message: 'The employee details response was invalid.',
        ),
      );
    } on FormatException {
      emit(
        EmployeeDetailStateError(
          message: 'The employee details response was invalid.',
        ),
      );
    }
  }
}

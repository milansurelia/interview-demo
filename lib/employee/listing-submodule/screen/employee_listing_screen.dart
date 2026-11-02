import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';
import 'package:tectonas_ems/core/di/initial_dependencies.dart';
import 'package:tectonas_ems/core/widgets/spacing.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';
import 'package:tectonas_ems/employee/listing-submodule/bloc/employee_listing_bloc.dart';
import 'package:tectonas_ems/employee/listing-submodule/screen/widgets/employee_listing_card.dart';

class EmployeeListingScreen extends StatefulWidget {
  const EmployeeListingScreen({super.key});

  @override
  State<EmployeeListingScreen> createState() => _EmployeeListingScreenState();
}

class _EmployeeListingScreenState extends State<EmployeeListingScreen> {
  final _searchController = TextEditingController();
  final _employeeCache = getIt<HiveOfflineService>();
  String _searchQuery = '';
  String? _selectedCompany;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Listing')),
      body: BlocProvider(
        create: (context) => EmployeeListingBloc(
          dio: getIt<Dio>(),
          employeeCache: _employeeCache,
        )..add(FetchEmployeeListingEvent()),
        child: BlocBuilder<EmployeeListingBloc, EmployeeListingState>(
          builder: (context, state) {
            final employees = state is EmployeeListingStateLoaded
                ? state.employees
                : null;
            final companies =
                (employees ??
                        _employeeCache.fetchEmployeeList() ??
                        const <EmployeeModel>[])
                    .map((employee) => employee.company.name)
                    .where((company) => company.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
            final selectedCompany = companies.contains(_selectedCompany)
                ? _selectedCompany
                : null;
            final visibleEmployees = employees == null
                ? null
                : _filterEmployees(employees, selectedCompany: selectedCompany);

            return RefreshIndicator(
              onRefresh: () => _refreshEmployees(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (query) {
                                  setState(() => _searchQuery = query);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search by name or email',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchQuery.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Clear search',
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                          },
                                        ),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            HSpace.small,
                            IconButton.filledTonal(
                              tooltip: selectedCompany == null
                                  ? 'Filter employees'
                                  : 'Filter employees (active)',
                              onPressed: employees == null
                                  ? null
                                  : () => _showFilters(
                                      context,
                                      companies,
                                      selectedCompany,
                                    ),
                              icon: Badge(
                                isLabelVisible: selectedCompany != null,
                                child: const Icon(Icons.tune),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (state is EmployeeListingStateLoaded && state.isFromCache)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Showing saved employee data'),
                    ),
                  VSpace.small,
                  ...switch (state) {
                    EmployeeListingStateLoading() => [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                    EmployeeListingStateError(:final message) => [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        child: Center(
                          child: Text(message, textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                    EmployeeListingStateLoaded() =>
                      visibleEmployees!.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(
                                  child: Text('No employees found'),
                                ),
                              ),
                            ]
                          : visibleEmployees
                                .map(
                                  (employee) => EmployeeListingCard(
                                    employeeId: employee.id,
                                    name: employee.name,
                                    email: employee.email,
                                    company: employee.company.name,
                                  ),
                                )
                                .toList(),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    List<String> companyNames,
    String? selectedCompany,
  ) async {
    var pendingCompany = selectedCompany;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                VSpace.small,
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        [
                              ('', 'All companies'),
                              ...companyNames.map(
                                (company) => (company, company),
                              ),
                            ]
                            .map(
                              (option) => RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                title: Text(option.$2),
                                value: option.$1,
                                groupValue: pendingCompany ?? '',
                                onChanged: (value) {
                                  setSheetState(() => pendingCompany = value);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
                VSpace.small,
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedCompany = null;
                        });
                        Navigator.of(sheetContext).pop();
                      },
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Clear filters'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        setState(
                          () => _selectedCompany =
                              pendingCompany == null || pendingCompany!.isEmpty
                              ? null
                              : pendingCompany,
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshEmployees(BuildContext context) async {
    final bloc = context.read<EmployeeListingBloc>();
    final refreshCompleted = bloc.stream.firstWhere(
      (state) =>
          state is EmployeeListingStateLoaded ||
          state is EmployeeListingStateError,
    );
    bloc.add(FetchEmployeeListingEvent());
    await refreshCompleted;
  }

  List<EmployeeModel> _filterEmployees(
    List<EmployeeModel> employees, {
    required String? selectedCompany,
  }) {
    final searchQuery = _searchQuery.trim().toLowerCase();
    return employees.where((employee) {
      final matchesText =
          searchQuery.isEmpty ||
          employee.name.toLowerCase().contains(searchQuery) ||
          employee.email.toLowerCase().contains(searchQuery);
      final matchesCompany =
          selectedCompany == null || employee.company.name == selectedCompany;
      return matchesText && matchesCompany;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

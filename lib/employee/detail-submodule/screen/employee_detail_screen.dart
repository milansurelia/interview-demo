import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';
import 'package:tectonas_ems/core/di/initial_dependencies.dart';
import 'package:tectonas_ems/core/widgets/spacing.dart';
import 'package:tectonas_ems/employee/detail-submodule/bloc/employee_detail_bloc.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});

  final int employeeId;

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Detail')),
      body: BlocProvider(
        create: (_) => EmployeeDetailBloc(
          dio: getIt<Dio>(),
          employeeCache: getIt<HiveOfflineService>(),
        )..add(FetchEmployeeDetailEvent(employeeId: widget.employeeId)),
        child: BlocBuilder<EmployeeDetailBloc, EmployeeDetailState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _refreshEmployee(context),
              child: switch (state) {
                EmployeeDetailStateLoading() => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.65,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                EmployeeDetailStateError(:final message) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.65,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 40),
                            VSpace.medium,
                            Text(message, textAlign: TextAlign.center),
                            VSpace.medium,
                            FilledButton.icon(
                              onPressed: () =>
                                  context.read<EmployeeDetailBloc>().add(
                                    FetchEmployeeDetailEvent(
                                      employeeId: widget.employeeId,
                                    ),
                                  ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                EmployeeDetailStateLoaded(
                  :final employeeDetail,
                  :final isFromCache,
                ) =>
                  _EmployeeDetails(
                    employee: employeeDetail,
                    isFromCache: isFromCache,
                  ),
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshEmployee(BuildContext context) async {
    final bloc = context.read<EmployeeDetailBloc>();
    final refreshCompleted = bloc.stream.firstWhere(
      (state) =>
          state is EmployeeDetailStateLoaded ||
          state is EmployeeDetailStateError,
    );
    bloc.add(FetchEmployeeDetailEvent(employeeId: widget.employeeId));
    await refreshCompleted;
  }
}

class _EmployeeDetails extends StatelessWidget {
  const _EmployeeDetails({required this.employee, required this.isFromCache});

  final EmployeeModel employee;
  final bool isFromCache;

  @override
  Widget build(BuildContext context) {
    final address = employee.address;
    final company = employee.company;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (isFromCache)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Showing saved employee data'),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        employee.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Text('Employee #${employee.id}'),
                  ],
                ),
                VSpace.xsmall,
                Text('Username: @${employee.username}'),
                VSpace.xsmall,
              ],
            ),
          ),
        ),
        VSpace.medium,
        _DetailSection(
          title: 'Contact',
          icon: Icons.contact_phone_outlined,
          details: [
            _DetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: employee.email,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: employee.phone,
              action: IconButton(
                tooltip: 'Call ${employee.name}',
                onPressed: employee.phone.trim().isEmpty
                    ? null
                    : () => _launchExternalUri(
                        context,
                        Uri(scheme: 'tel', path: employee.phone.trim()),
                      ),
                iconSize: 14,
                icon: const Icon(Icons.call_outlined),
              ),
            ),
            _DetailRow(
              icon: Icons.language,
              label: 'Website',
              value: employee.website,
            ),
          ],
        ),
        VSpace.medium,
        _DetailSection(
          title: 'Address',
          icon: Icons.location_on_outlined,
          details: [
            _DetailRow(
              icon: Icons.home_outlined,
              label: 'Street',
              value: '${address.street}, ${address.suite}',
            ),
            _DetailRow(
              icon: Icons.location_city_outlined,
              label: 'City',
              value: '${address.city}, ${address.zipcode}',
            ),
            _DetailRow(
              icon: Icons.my_location,
              label: 'Coordinates',
              value: '${address.geo.lat}, ${address.geo.lng}',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                onPressed: _hasCoordinates(address.geo.lat, address.geo.lng)
                    ? () => _launchExternalUri(
                        context,
                        Uri.https('www.google.com', '/maps/search/', {
                          'api': '1',
                          'query': '${address.geo.lat},${address.geo.lng}',
                        }),
                      )
                    : null,
                icon: const Icon(Icons.map_outlined),
                label: const Text('View on map'),
              ),
            ),
          ],
        ),
        VSpace.medium,
        _DetailSection(
          title: 'Company',
          icon: Icons.business_outlined,
          details: [
            _DetailRow(
              icon: Icons.business,
              label: 'Name',
              value: company.name,
            ),
            _DetailRow(
              icon: Icons.format_quote_outlined,
              label: 'Catch phrase',
              value: company.catchPhrase,
            ),
            _DetailRow(
              icon: Icons.work_outline,
              label: 'Business',
              value: company.bs,
            ),
          ],
        ),
      ],
    );
  }
}

bool _hasCoordinates(String latitude, String longitude) {
  final lat = double.tryParse(latitude);
  final lng = double.tryParse(longitude);
  return lat != null &&
      lng != null &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180;
}

Future<void> _launchExternalUri(BuildContext context, Uri uri) async {
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link.')),
      );
    }
  } on PlatformException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link.')),
      );
    }
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.details,
  });

  final String title;
  final IconData icon;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                HSpace.small,
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            VSpace.small,
            ...details,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          HSpace.medium,
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(child: SelectableText(value)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

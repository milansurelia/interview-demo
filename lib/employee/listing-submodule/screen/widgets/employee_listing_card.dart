import 'package:flutter/material.dart';
import 'package:tectonas_ems/core/widgets/spacing.dart';
import 'package:tectonas_ems/employee/detail-submodule/screen/employee_detail_screen.dart';

class EmployeeListingCard extends StatelessWidget {
  const EmployeeListingCard({
    super.key,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.company,
  });

  final int employeeId;
  final String name;
  final String email;
  final String company;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EmployeeDetailScreen(employeeId: employeeId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    VSpace.small,
                    _EmployeeCardDetail(
                      icon: Icons.email_outlined,
                      value: email,
                    ),
                    VSpace.small,
                    _EmployeeCardDetail(
                      icon: Icons.business_outlined,
                      value: company,
                    ),
                  ],
                ),
              ),
              HSpace.small,
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeCardDetail extends StatelessWidget {
  const _EmployeeCardDetail({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        HSpace.small,
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

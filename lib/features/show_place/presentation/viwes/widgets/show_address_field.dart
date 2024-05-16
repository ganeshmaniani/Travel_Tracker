import 'package:flutter/material.dart';

import '../../../../search_plcae/presentation/views/widgets/address_connector.dart';

class ShowAddressField extends StatelessWidget {
  const ShowAddressField({
    super.key,
    required this.fromOrTo,
    required this.address,
    required this.isFirst,
    required this.isLast,
    required this.color,
  });
  final String fromOrTo;
  final String address;
  final bool isFirst;
  final bool isLast;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return AddressCardContainer(
      isFirst: isFirst,
      isLast: isLast,
      isPass: true,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fromOrTo, style: Theme.of(context).textTheme.labelLarge),
          Text(address,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

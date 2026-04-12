// import 'package:fitness_management_app/config/constants.dart';
// import 'package:flutter/material.dart';

// class SubscriptionCard extends StatelessWidget {
//   const SubscriptionCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // TODO: Fetch from API/Database
//     final hasActiveSubscription = true;
//     final subscriptionName = 'Premium Gym Membership';
//     final location = 'Fitness First - Downtown';
//     final daysRemaining = 18;
//     final visitsThisMonth = 12;

//     // ignore: dead_code
//     if (!hasActiveSubscription) {
//       return _buildNoSubscriptionCard(context);
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               AppConstants.subscriptionGradientStart,
//               AppConstants.subscriptionGradientEnd
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.purple.withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
//             onTap: () {
//               // TODO: Navigate to subscription details with QR code
//               // Navigator.pushNamed(context, '/subscription-details');
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(AppConstants.paddingLarge),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.card_membership, color: Colors.white, size: 28),
//                           SizedBox(width: 12),
//                           Text(
//                             'Active Subscription',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text(
//                           'ACTIVE',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               subscriptionName,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               location,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.qr_code,
//                           color: AppConstants.subscriptionGradientStart,
//                           size: 32,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Days Remaining',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '$daysRemaining days',
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'This Month',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '$visitsThisMonth visits',
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNoSubscriptionCard(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
//       child: Container(
//         padding: const EdgeInsets.all(AppConstants.paddingLarge),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Column(
//           children: [
//             const Icon(Icons.info_outline, size: 48, color: Colors.grey),
//             const SizedBox(height: 12),
//             const Text(
//               'No Active Subscription',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Browse programs and get started today!',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Navigate to programs
//                 // Navigator.pushNamed(context, '/programs');
//               },
//               child: const Text('Browse Programs'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
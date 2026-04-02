import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'models.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = Provider.of<AuthProvider>(context, listen: false).apiService.getBookings();
  }

  void _cancelBooking(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.apiService.updateBooking(id, {'status': 'cancelled'});
    if (res != null) {
      setState(() {
        _bookingsFuture = auth.apiService.getBookings();
      });
    }
  }

  void _refreshBookings() {
    setState(() {
      _bookingsFuture = Provider.of<AuthProvider>(context, listen: false).apiService.getBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBookings,
            tooltip: 'Refresh Bookings',
          ),
        ],
      ),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(booking.serviceName),
                  subtitle: Text('${booking.date} at ${booking.time} - Status: ${booking.status.toUpperCase()}'),
                  trailing: booking.status == 'pending'
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelBooking(booking.id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

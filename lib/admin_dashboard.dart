import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'models.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Service>> _servicesFuture;
  
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final api = Provider.of<AuthProvider>(context, listen: false).apiService;
    setState(() {
      _bookingsFuture = api.getBookings();
      _servicesFuture = api.getServices();
    });
  }

  void _clearControllers() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _durationController.clear();
  }

  void _addOrUpdateService({Service? existingService}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final serviceData = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'duration': int.tryParse(_durationController.text) ?? 0,
    };
    
    Service? res;
    if (existingService != null) {
     final res = await auth.apiService.updateService(existingService.id, serviceData);
    } else {
      res = await auth.apiService.createService(serviceData);
    }

    if (res != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existingService != null ? 'Service Updated!' : 'Service Added!')));
      Navigator.of(context).maybePop(); // Safe pop
      _refreshData();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operation failed. Session data might be unavailable.')),
      );
    }
  }

  void _deleteService(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.apiService.deleteService(id);
    if (success) {
      _refreshData();
    }
  }

  void _updateBookingStatus(String id, String status) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.apiService.updateBooking(id, {'status': status});
    if (res != null) {
      _refreshData();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking. Session may have reset on server.')),
      );
    }
  }

  void _showServiceDialog({Service? service}) {
    if (service != null) {
      _nameController.text = service.name;
      _descController.text = service.description;
      _priceController.text = service.price.toString();
      _durationController.text = service.duration.toString();
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service != null ? 'Edit Service' : 'Add New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Duration (mins)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _addOrUpdateService(existingService: service), child: Text(service != null ? 'Update' : 'Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bookings'),
              Tab(text: 'Services'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Bookings Tab
            RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: FutureBuilder<List<Booking>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No bookings found.'));
                  final bookings = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('${b.serviceName} (${b.status.toUpperCase()})'),
                          subtitle: Text('User: ${b.userName}\nDate: ${b.date} at ${b.time}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) => _updateBookingStatus(b.id, val),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                              const PopupMenuItem(value: 'completed', child: Text('Complete')),
                              const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Services Tab
            RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: FutureBuilder<List<Service>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No services found.'));
                  final services = snapshot.data!;
                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text('\$${s.price} - ${s.duration} mins'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showServiceDialog(service: s)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteService(s.id)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showServiceDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

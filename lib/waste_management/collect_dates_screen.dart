import 'package:flutter/material.dart';
import 'package:ecopulse_local/waste_management/waste_service.dart';
import 'package:ecopulse_local/models/collectionschedule.dart';
import 'package:intl/intl.dart';

class CollectionDatesScreen extends StatefulWidget {
  const CollectionDatesScreen({Key? key}) : super(key: key);

  @override
  _CollectionDatesScreenState createState() => _CollectionDatesScreenState();
}

class _CollectionDatesScreenState extends State<CollectionDatesScreen> {
  final WasteService _wasteService = WasteService();
  bool _isLoading = true;
  List<CollectionSchedule> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCollectionSchedules();
  }

  Future<void> _loadCollectionSchedules() async {
    try {
      final schedules = await _wasteService.getCollectionSchedules(context);
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load collection schedules: $e';
        _isLoading = false;
      });
    }
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Dates'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadCollectionSchedules();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _schedules.isEmpty
                  ? const Center(
                      child: Text('No collection schedules found for your area.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCollectionSchedules,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _schedules[index];
                          final isToday = schedule.date.day == DateTime.now().day &&
                                          schedule.date.month == DateTime.now().month &&
                                          schedule.date.year == DateTime.now().year;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isToday
                                    ? Border.all(color: Colors.green, width: 2)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date Column
                                    Container(
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: isToday ? Colors.green : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat('d').format(schedule.date),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: isToday ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM').format(schedule.date),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isToday ? Colors.white : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Details Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _getRelativeDateText(schedule.date),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (isToday)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text(
                                                    'TODAY',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Collection Type: ${schedule.wasteType}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Time: ${DateFormat('h:mm a').format(schedule.date)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (schedule.notes != null && schedule.notes!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                schedule.notes!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
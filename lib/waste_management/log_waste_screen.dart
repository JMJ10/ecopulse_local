import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecopulse_local/providers/user_provider.dart';
import 'package:ecopulse_local/waste_management/waste_service.dart';
import 'package:ecopulse_local/models/wastelog.dart';

class LogWasteScreen extends StatefulWidget {
  const LogWasteScreen({Key? key}) : super(key: key);

  @override
  _LogWasteScreenState createState() => _LogWasteScreenState();
}

class _LogWasteScreenState extends State<LogWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final WasteService _wasteService = WasteService();
  
  String _selectedWasteType = 'Plastic';
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  
  final List<String> _wasteTypes = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Organic',
    'Electronic',
    'Other'
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitWasteLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final notes = _notesController.text;
      
      final log = WasteLog(
        id: '',
        userId: Provider.of<UserProvider>(context, listen: false).user.id,
        wasteType: _selectedWasteType,
        quantity: quantity,
        units: 'kg',
        notes: notes,
        logDate: DateTime.now(),
      );
      
      await _wasteService.logWaste(context, log);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waste logged successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging waste: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Waste'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waste Type Selector
              const Text(
                'Waste Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedWasteType,
                    items: _wasteTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedWasteType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quantity Input
              const Text(
                'Quantity (kg)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter amount in kilograms',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  try {
                    double quantity = double.parse(value);
                    if (quantity <= 0) {
                      return 'Quantity must be greater than zero';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Notes Input
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any additional information',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitWasteLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Log Waste',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
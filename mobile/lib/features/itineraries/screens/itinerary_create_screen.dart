import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/itinerary_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/listings_provider.dart';
import '../../../core/providers/country_provider.dart';
import '../../../core/models/itinerary.dart';
import '../../../core/services/itinerary_service.dart';

class ItineraryCreateScreen extends ConsumerStatefulWidget {
  final Itinerary? itinerary; // If provided, we're editing

  const ItineraryCreateScreen({super.key, this.itinerary});

  @override
  ConsumerState<ItineraryCreateScreen> createState() => _ItineraryCreateScreenState();
}

class _ItineraryCreateScreenState extends ConsumerState<ItineraryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isPublic = false;
  List<ItineraryItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.itinerary != null) {
      final itinerary = widget.itinerary!;
      _titleController.text = itinerary.title;
      _descriptionController.text = itinerary.description ?? '';
      _locationController.text = itinerary.location ?? '';
      _startDate = itinerary.startDate;
      _endDate = itinerary.endDate;
      _isPublic = itinerary.isPublic;
      _items = List.from(itinerary.items);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itinerary != null;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Itinerary' : 'Create Itinerary',
          style: context.titleLarge,
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteDialog,
              tooltip: 'Delete Itinerary',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., My Rwanda Adventure',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Tell us about your trip...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStartDate: true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(_startDate),
                        style: context.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStartDate: false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.event),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(_endDate),
                        style: context.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., Kigali, Rwanda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            
            // Public toggle
            SwitchListTile(
              title: const Text('Make Public'),
              subtitle: const Text('Allow others to view this itinerary'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Add Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Itinerary Items',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddItemMenu,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.primaryColorTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Items List
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.grey200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_location_alt,
                        size: 48,
                        color: context.secondaryTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items added yet',
                        style: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add places, events, or tours to your itinerary',
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemCard(item, index);
              }),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveItinerary,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColorTheme,
                foregroundColor: Colors.white,
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
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Update Itinerary' : 'Create Itinerary',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ItineraryItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.grey200),
      ),
      child: Row(
        children: [
          // Drag handle
          Icon(
            Icons.drag_handle,
            color: context.secondaryTextColor,
          ),
          const SizedBox(width: 12),
          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(item),
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(item.startTime),
                  style: context.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: context.errorColor,
            onPressed: () {
              setState(() {
                _items.removeAt(index);
                // Reorder items
                for (int i = 0; i < _items.length; i++) {
                  _items[i] = _items[i].copyWith(order: i);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String _getItemName(ItineraryItem item) {
    switch (item.type) {
      case ItineraryItemType.listing:
        return item.metadata?['name'] ?? 'Place';
      case ItineraryItemType.event:
        return item.metadata?['name'] ?? 'Event';
      case ItineraryItemType.tour:
        return item.metadata?['name'] ?? 'Tour';
      case ItineraryItemType.custom:
        return item.customName ?? 'Custom Item';
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _showAddItemMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.secondaryTextColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('From Favorites'),
              subtitle: const Text('Add from your saved favorites'),
              onTap: () {
                Navigator.pop(context);
                _addFromFavorites();
              },
            ),
            ListTile(
              leading: const Icon(Icons.recommend),
              title: const Text('From Recommendations'),
              subtitle: const Text('Add from recommended places'),
              onTap: () {
                Navigator.pop(context);
                _addFromRecommendations();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt),
              title: const Text('Custom Item'),
              subtitle: const Text('Add a custom location or activity'),
              onTap: () {
                Navigator.pop(context);
                _addCustomItem();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _addFromFavorites() {
    context.push('/itineraries/add-from-favorites').then((result) {
      if (result != null && result is List) {
        for (final item in result) {
          if (item is Map<String, dynamic>) {
            _addItemFromResult(item);
          }
        }
      } else if (result != null && result is Map<String, dynamic>) {
        _addItemFromResult(result);
      }
    });
  }

  void _addFromRecommendations() {
    context.push('/itineraries/add-from-recommendations').then((result) {
      if (result != null && result is List) {
        for (final item in result) {
          if (item is Map<String, dynamic>) {
            _addItemFromResult(item);
          }
        }
      } else if (result != null && result is Map<String, dynamic>) {
        _addItemFromResult(result);
      }
    });
  }

  void _addCustomItem() {
    showDialog(
      context: context,
      builder: (context) => _CustomItemDialog(
        onSave: (item) {
          setState(() {
            _items.add(item.copyWith(
              itineraryId: widget.itinerary?.id ?? '',
              order: _items.length,
            ));
          });
        },
      ),
    );
  }

  void _addItemFromResult(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final id = result['id'] as String;
    final name = result['name'] as String? ?? '';
    final metadata = result['metadata'] as Map<String, dynamic>? ?? {};
    
    ItineraryItemType itemType;
    if (type == 'listing') {
      itemType = ItineraryItemType.listing;
    } else if (type == 'event') {
      itemType = ItineraryItemType.event;
    } else if (type == 'tour') {
      itemType = ItineraryItemType.tour;
    } else {
      return;
    }

    final item = ItineraryItem(
      itineraryId: widget.itinerary?.id ?? '',
      type: itemType,
      listingId: type == 'listing' ? id : null,
      eventId: type == 'event' ? id : null,
      tourId: type == 'tour' ? id : null,
      startTime: _startDate,
      order: _items.length,
      metadata: {
        ...metadata,
        'name': name,
      },
    );

    setState(() {
      _items.add(item);
    });
  }

  Future<void> _saveItinerary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedCountry = ref.read(selectedCountryProvider).value;
      final itineraryService = ref.read(itineraryServiceProvider);
      
      if (widget.itinerary != null) {
        // Update existing
        await itineraryService.updateItinerary(
          itineraryId: widget.itinerary!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          countryId: selectedCountry?.id,
          isPublic: _isPublic,
          items: _items,
        );
      } else {
        // Create new
        await itineraryService.createItinerary(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          countryId: selectedCountry?.id,
          isPublic: _isPublic,
          items: _items,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.itinerary != null 
                  ? 'Itinerary updated successfully' 
                  : 'Itinerary created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Itinerary'),
        content: const Text('Are you sure you want to delete this itinerary? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteItinerary();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItinerary() async {
    try {
      final itineraryService = ref.read(itineraryServiceProvider);
      await itineraryService.deleteItinerary(widget.itinerary!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Itinerary deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CustomItemDialog extends StatefulWidget {
  final Function(ItineraryItem) onSave;

  const _CustomItemDialog({required this.onSave});

  @override
  State<_CustomItemDialog> createState() => _CustomItemDialogState();
}

class _CustomItemDialogState extends State<_CustomItemDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startTime = DateTime.now();
  int? _durationMinutes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Coffee Break',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_startTime),
                );
                if (time != null) {
                  setState(() {
                    _startTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(DateFormat('h:mm a').format(_startTime)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Duration (minutes, optional)',
                hintText: 'e.g., 60',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _durationMinutes = int.tryParse(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a name')),
              );
              return;
            }
            
            final item = ItineraryItem(
              itineraryId: '',
              type: ItineraryItemType.custom,
              customName: _nameController.text.trim(),
              customDescription: _descriptionController.text.trim().isEmpty 
                  ? null 
                  : _descriptionController.text.trim(),
              customLocation: _locationController.text.trim().isEmpty 
                  ? null 
                  : _locationController.text.trim(),
              startTime: _startTime,
              durationMinutes: _durationMinutes,
              order: 0,
            );
            
            widget.onSave(item);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}


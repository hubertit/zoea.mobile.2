import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/event.dart';

class EventFormScreen extends StatefulWidget {
  final String? eventId;

  const EventFormScreen({super.key, this.eventId});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _venueAddressController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  String? _selectedCategory;
  bool _isPrivate = false;
  final List<EventTicket> _tickets = [];

  bool get isEditing => widget.eventId != null;

  final _categories = [
    'Conference',
    'Music',
    'Business',
    'Art',
    'Sports',
    'Food & Drink',
    'Networking',
    'Workshop',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _venueAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          isEditing ? 'Edit Event' : 'Create Event',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAsDraft,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save Draft',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Event Flyer
            _buildFlyerUpload(),
            const SizedBox(height: AppTheme.spacing24),

            // Basic Info Section
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: AppTheme.spacing12),
            _buildTextField(
              controller: _nameController,
              label: 'Event Name',
              hint: 'Enter event name',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: AppTheme.spacing16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your event',
              maxLines: 4,
            ),
            const SizedBox(height: AppTheme.spacing16),
            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Date & Time Section
            _buildSectionTitle('Date & Time'),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Start Date',
                    date: _startDate,
                    onChanged: (d) => setState(() => _startDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Start Time',
                    time: _startTime,
                    onChanged: (t) => setState(() => _startTime = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'End Date',
                    date: _endDate,
                    onChanged: (d) => setState(() => _endDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: 'End Time',
                    time: _endTime,
                    onChanged: (t) => setState(() => _endTime = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Location Section
            _buildSectionTitle('Location'),
            const SizedBox(height: AppTheme.spacing12),
            _buildTextField(
              controller: _venueController,
              label: 'Venue Name',
              hint: 'e.g., Kigali Convention Centre',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: AppTheme.spacing16),
            _buildTextField(
              controller: _venueAddressController,
              label: 'Address',
              hint: 'Full address',
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Tickets Section
            _buildSectionTitle('Tickets'),
            const SizedBox(height: AppTheme.spacing12),
            _buildTicketsList(),
            const SizedBox(height: AppTheme.spacing12),
            OutlinedButton.icon(
              onPressed: _addTicket,
              icon: const Icon(Icons.add),
              label: const Text('Add Ticket Type'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Settings Section
            _buildSectionTitle('Settings'),
            const SizedBox(height: AppTheme.spacing12),
            SwitchListTile(
              value: _isPrivate,
              onChanged: (v) => setState(() => _isPrivate = v),
              title: const Text('Private Event'),
              subtitle: const Text('Only visible to invited guests'),
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Publish Button
            ElevatedButton(
              onPressed: _publishEvent,
              child: const Text('Publish Event'),
            ),
            const SizedBox(height: AppTheme.spacing16),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyerUpload() {
    return GestureDetector(
      onTap: () {
        // TODO: Image picker
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
          border: Border.all(
            color: AppTheme.dividerColor,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload Event Flyer',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Recommended: 1080x1920px',
              style: AppTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(date)),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time.format(context)),
            const Icon(Icons.access_time, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
        ),
        child: Text(
          'No tickets added yet',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryTextColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: _tickets.asMap().entries.map((entry) {
        final ticket = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.name,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ticket.price > 0
                          ? 'RWF ${NumberFormat('#,###').format(ticket.price)} • ${ticket.quantity} available'
                          : 'Free • ${ticket.quantity} available',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editTicket(entry.key),
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              IconButton(
                onPressed: () => setState(() => _tickets.removeAt(entry.key)),
                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.errorColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _addTicket() {
    _showTicketDialog();
  }

  void _editTicket(int index) {
    _showTicketDialog(ticket: _tickets[index], index: index);
  }

  void _showTicketDialog({EventTicket? ticket, int? index}) {
    final nameController = TextEditingController(text: ticket?.name ?? '');
    final priceController = TextEditingController(
      text: ticket?.price.toInt().toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: ticket?.quantity.toString() ?? '',
    );
    TicketType selectedType = ticket?.type ?? TicketType.paid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  ticket == null ? 'Add Ticket' : 'Edit Ticket',
                  style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ticket Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TicketType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TicketType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          ))
                      .toList(),
                  onChanged: (v) => setSheetState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                if (selectedType != TicketType.free)
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (RWF)',
                    ),
                  ),
                if (selectedType != TicketType.free)
                  const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newTicket = EventTicket(
                        id: ticket?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        type: selectedType,
                        price: selectedType == TicketType.free
                            ? 0
                            : double.tryParse(priceController.text) ?? 0,
                        quantity: int.tryParse(quantityController.text) ?? 0,
                      );
                      setState(() {
                        if (index != null) {
                          _tickets[index] = newTicket;
                        } else {
                          _tickets.add(newTicket);
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(ticket == null ? 'Add Ticket' : 'Save'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _saveAsDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final event = _buildEvent(EventStatus.draft);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('Saving draft event: ${event.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(message: 'Event saved as draft'),
        );
        context.pop(event);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Failed to save draft'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _publishEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(message: 'Please add at least one ticket type'),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final event = _buildEvent(EventStatus.published);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('Publishing event: ${event.name}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.successSnackBar(message: 'Event published successfully'),
        );
        context.pop(event);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message: 'Failed to publish event'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Event _buildEvent(EventStatus status) {
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    return Event(
      id: widget.eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: 'current_business_id',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: startDateTime,
      endDate: endDateTime,
      venue: _venueController.text.trim(),
      venueAddress: _venueAddressController.text.trim().isNotEmpty 
          ? _venueAddressController.text.trim() 
          : null,
      status: status,
      privacy: _isPrivate ? EventPrivacy.private : EventPrivacy.public,
      tickets: _tickets,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}


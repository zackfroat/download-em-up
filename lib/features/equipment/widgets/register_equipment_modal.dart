import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/equipment_maintenance_item.dart';

/// Modal to register new machinery matching Steps 1-5 of the Flowchart
class RegisterEquipmentModal extends StatefulWidget {
  final ValueChanged<EquipmentMaintenanceItem> onRegistered;

  const RegisterEquipmentModal({
    super.key,
    required this.onRegistered,
  });

  @override
  State<RegisterEquipmentModal> createState() => _RegisterEquipmentModalState();
}

class _RegisterEquipmentModalState extends State<RegisterEquipmentModal> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _serialController = TextEditingController();
  final _specsController = TextEditingController();
  final _locationController = TextEditingController();
  final _operatingHoursController = TextEditingController(text: '0');
  final _picController = TextEditingController();
  final _picContactController = TextEditingController();
  final _teamController = TextEditingController(text: 'Internal Mechanical Plant Crew');
  final _scheduleNotesController = TextEditingController();

  String _selectedCategory = 'Heavy Earthmoving';
  WearAndTearStatus _wearStatus = WearAndTearStatus.good;
  DateTime _warrantyExpiry = DateTime.now().add(const Duration(days: 365));
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 90));

  final List<String> _categories = [
    'Heavy Earthmoving',
    'Lifting & Rigging',
    'Power Generation',
    'Compaction Machinery',
    'Concrete & Pumping',
    'Haulage & Transport',
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _serialController.dispose();
    _specsController.dispose();
    _locationController.dispose();
    _operatingHoursController.dispose();
    _picController.dispose();
    _picContactController.dispose();
    _teamController.dispose();
    _scheduleNotesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newItem = EquipmentMaintenanceItem(
      id: 'EQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      equipmentCode: _codeController.text.trim().toUpperCase(),
      equipmentName: _nameController.text.trim(),
      category: _selectedCategory,
      brandAndModel: _brandController.text.trim(),
      serialNumber: _serialController.text.trim().toUpperCase(),
      specifications: _specsController.text.trim(),
      locationSite: _locationController.text.trim(),
      operatingHours: int.tryParse(_operatingHoursController.text.trim()) ?? 0,
      registrationDate: DateTime.now(),
      warrantyExpiry: _warrantyExpiry,
      roadTaxOrInspectionExpiry: _warrantyExpiry.subtract(const Duration(days: 60)),
      wearAndTear: _wearStatus,
      scheduledMaintenanceDate: _scheduledDate,
      estimatedScheduleNotes: _scheduleNotesController.text.trim().isEmpty
          ? 'Scheduled routine preventative service & multi-point inspection.'
          : _scheduleNotesController.text.trim(),
      isCalendarSynced: true,
      equipmentPic: _picController.text.trim(),
      picContact: _picContactController.text.trim(),
      assignedMaintenanceTeam: _teamController.text.trim(),
      stage: EquipmentMaintenanceStage.scheduleRecorded,
    );

    widget.onRegistered(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 560;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 14 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_to_photos_rounded,
                      color: Color(0xFFF97316),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register Equipment & Machinery',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Flowchart Steps 1-5: Specifications, Warranty, Wear & Tear & Calendar Sync',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Identification
                      _buildSectionTitle('1. Equipment Identification (Step 1)'),
                      const SizedBox(height: 10),
                      if (isMobile) ...[
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Equipment Code *',
                            hintText: 'e.g. EQ-EXC-09',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Equipment Name *',
                            hintText: 'e.g. Hydraulic Excavator CAT 320',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Machinery Category',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand & Model *',
                            hintText: 'e.g. Komatsu PC200-8',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _codeController,
                                decoration: const InputDecoration(
                                  labelText: 'Equipment Code *',
                                  hintText: 'e.g. EQ-EXC-09',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Equipment Name *',
                                  hintText: 'e.g. Hydraulic Excavator CAT 320',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Machinery Category',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v!),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _brandController,
                                decoration: const InputDecoration(
                                  labelText: 'Brand & Model *',
                                  hintText: 'e.g. Komatsu PC200-8',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Section 2: Specs & Details
                      _buildSectionTitle('2. Specifications & Details (Step 2)'),
                      const SizedBox(height: 10),
                      if (isMobile) ...[
                        TextFormField(
                          controller: _serialController,
                          decoration: const InputDecoration(
                            labelText: 'Chassis / Serial Number *',
                            hintText: 'e.g. KM-PC200-78192',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _operatingHoursController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Operating Hours (hrs)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _serialController,
                                decoration: const InputDecoration(
                                  labelText: 'Chassis / Serial Number *',
                                  hintText: 'e.g. KM-PC200-78192',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _operatingHoursController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Operating Hours (hrs)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _specsController,
                        decoration: const InputDecoration(
                          labelText: 'Technical Specifications',
                          hintText: 'e.g. Engine horsepower, hydraulic pressure, bucket/crane capacity...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Operational Site Location',
                          hintText: 'e.g. Sector 4 - Bridge Abutment Staging',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 3: Wear & Tear, Expiry & Warranty
                      _buildSectionTitle('3. Expiry, Wear & Tear and Warranty (Step 3)'),
                      const SizedBox(height: 10),
                      if (isMobile) ...[
                        DropdownButtonFormField<WearAndTearStatus>(
                          initialValue: _wearStatus,
                          decoration: const InputDecoration(
                            labelText: 'Wear & Tear Assessment',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: WearAndTearStatus.values
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setState(() => _wearStatus = v!),
                        ),
                        const SizedBox(height: 12),
                        _buildDatePicker(
                          label: 'Warranty Expiry Date',
                          date: _warrantyExpiry,
                          onPick: (d) => setState(() => _warrantyExpiry = d),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<WearAndTearStatus>(
                                initialValue: _wearStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Wear & Tear Assessment',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: WearAndTearStatus.values
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13))))
                                    .toList(),
                                onChanged: (v) => setState(() => _wearStatus = v!),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Warranty Expiry Date',
                                date: _warrantyExpiry,
                                onPick: (d) => setState(() => _warrantyExpiry = d),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Section 4: Store Team Schedule & Calendar
                      _buildSectionTitle('4. Store Team Schedule & Calendar (Steps 4-5)'),
                      const SizedBox(height: 10),
                      if (isMobile) ...[
                        _buildDatePicker(
                          label: 'Estimated Maintenance Date',
                          date: _scheduledDate,
                          onPick: (d) => setState(() => _scheduledDate = d),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Color(0xFF16A34A), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Auto-syncs to Master Equipment Calendar',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Estimated Maintenance Date',
                                date: _scheduledDate,
                                onPick: (d) => setState(() => _scheduledDate = d),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: Color(0xFF16A34A), size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Auto-syncs to Master Equipment Calendar',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _scheduleNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Maintenance Notes',
                          hintText: 'e.g. 1000-hr lubrication, replacement of hydraulic return filters...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 5: Equipment PIC & Maintenance Team
                      _buildSectionTitle('5. Equipment PIC & Assigned Team (Steps 9-11)'),
                      const SizedBox(height: 10),
                      if (isMobile) ...[
                        TextFormField(
                          controller: _picController,
                          decoration: const InputDecoration(
                            labelText: 'Equipment PIC Name *',
                            hintText: 'e.g. Ir. Ahmad Razali',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _picContactController,
                          decoration: const InputDecoration(
                            labelText: 'PIC Contact No. *',
                            hintText: 'e.g. +60 12-882 1092',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _picController,
                                decoration: const InputDecoration(
                                  labelText: 'Equipment PIC Name *',
                                  hintText: 'e.g. Ir. Ahmad Razali',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _picContactController,
                                decoration: const InputDecoration(
                                  labelText: 'PIC Contact No. *',
                                  hintText: 'e.g. +60 12-882 1092',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _teamController,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Maintenance Team',
                          hintText: 'e.g. UMW Heavy Machinery Field Service Crew',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.borderLight),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Register & Sync to Calendar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onPick,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

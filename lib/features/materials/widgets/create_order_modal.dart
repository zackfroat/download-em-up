import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/procurement_order.dart';

/// Modal dialog for adding a new Purchase Order into the Procurement & Material Tracking pipeline
class CreateOrderModal extends StatefulWidget {
  final Function(ProcurementOrder newOrder) onOrderCreated;

  const CreateOrderModal({
    super.key,
    required this.onOrderCreated,
  });

  @override
  State<CreateOrderModal> createState() => _CreateOrderModalState();
}

class _CreateOrderModalState extends State<CreateOrderModal> {
  final _formKey = GlobalKey<FormState>();

  final _poController = TextEditingController(
      text: 'PO-MTR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
  final _supplierController = TextEditingController();
  final _contactController = TextEditingController();
  final _siteController = TextEditingController(text: 'Tower A - Main Structure');
  final _itemNameController = TextEditingController();
  final _specController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController(text: 'Tons');

  @override
  void dispose() {
    _poController.dispose();
    _supplierController.dispose();
    _contactController.dispose();
    _siteController.dispose();
    _itemNameController.dispose();
    _specController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final qty = int.tryParse(_qtyController.text.trim()) ?? 100;
      final newOrder = ProcurementOrder(
        id: 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        poNumber: _poController.text.trim(),
        supplierName: _supplierController.text.trim(),
        supplierContact: _contactController.text.trim(),
        projectSite: _siteController.text.trim(),
        items: [
          ProcurementItem(
            itemName: _itemNameController.text.trim(),
            specification: _specController.text.trim(),
            orderedQuantity: qty,
            unit: _unitController.text.trim(),
          ),
        ],
        stage: ProcurementWorkflowStage.poApproved,
        createdDate: DateTime.now(),
        sitePicName: 'Engr. David Wong (Site PIC)',
      );

      widget.onOrderCreated(newOrder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 14 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Procurement Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enters workflow at Stage 1: PO Approved by Management',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 12),

                  // PO Number & Project Site
                  TextFormField(
                    controller: _poController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order (PO) Number',
                    ),
                    validator: (v) => v!.isEmpty ? 'PO number required' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _supplierController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier / Vendor Name',
                      hintText: 'e.g. Megasteel Solutions Ltd',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Supplier name required' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Contact / Person',
                      hintText: 'e.g. +60 12-345 6789 (Mr. Tan)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _siteController,
                    decoration: const InputDecoration(
                      labelText: 'Project Site Location',
                      hintText: 'e.g. Tower A - Substructure Bay 3',
                    ),
                    validator: (v) => v!.isEmpty ? 'Site location required' : null,
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Material Lot Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Material Description',
                      hintText: 'e.g. Deformed Steel Bar (T25)',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Material description required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _specController,
                    decoration: const InputDecoration(
                      labelText: 'Specification / Grade',
                      hintText: 'e.g. BS 4449 Grade 500B / 12m',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Ordered Quantity',
                            hintText: '100',
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Quantity required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            hintText: 'Tons, m³, Sheets, Bags',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Initialize Procurement Workflow',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


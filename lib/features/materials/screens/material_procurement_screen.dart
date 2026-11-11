import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../models/procurement_order.dart';
import '../widgets/create_order_modal.dart';
import '../widgets/order_detail_sheet.dart';
import '../widgets/workflow_diagram_dialog.dart';
import '../widgets/workflow_pipeline_widget.dart';

/// Full screen interface for Module 06: Material Tracking & Procurement Monitoring System
/// adhering to the exact workflow flowchart.
class MaterialProcurementScreen extends StatefulWidget {
  final String roleName;

  const MaterialProcurementScreen({
    super.key,
    required this.roleName,
  });

  @override
  State<MaterialProcurementScreen> createState() =>
      _MaterialProcurementScreenState();
}

class _MaterialProcurementScreenState extends State<MaterialProcurementScreen> {
  late List<ProcurementOrder> _orders;
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Readiness, 2: Scheduled, 3: Shortage, 4: Completed

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All Active Orders',
    'Site Readiness Check',
    'Scheduled Deliveries',
    'Stock Take & Shortage',
    'Completed (POD Uploaded)',
  ];

  @override
  void initState() {
    super.initState();
    _orders = List.from(ProcurementOrder.initialSampleOrders);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProcurementOrder> get _filteredOrders {
    return _orders.where((order) {
      // 1. Filter tab check
      if (_selectedFilterIndex == 1 &&
          order.stage != ProcurementWorkflowStage.siteReadinessCheck &&
          order.stage != ProcurementWorkflowStage.supplierContacted) {
        return false;
      }
      if (_selectedFilterIndex == 2 &&
          order.stage != ProcurementWorkflowStage.deliveryScheduled) {
        return false;
      }
      if (_selectedFilterIndex == 3 &&
          order.stage != ProcurementWorkflowStage.siteStockTake &&
          order.stage != ProcurementWorkflowStage.shortageHandling) {
        return false;
      }
      if (_selectedFilterIndex == 4 &&
          order.stage != ProcurementWorkflowStage.completed &&
          order.stage != ProcurementWorkflowStage.doVerification) {
        return false;
      }

      // 2. Search query check
      if (_searchQuery.isNotEmpty) {
        final poMatch = order.poNumber.toLowerCase().contains(_searchQuery);
        final supplierMatch =
            order.supplierName.toLowerCase().contains(_searchQuery);
        final siteMatch = order.projectSite.toLowerCase().contains(_searchQuery);
        final itemMatch = order.items.any((i) =>
            i.itemName.toLowerCase().contains(_searchQuery) ||
            i.specification.toLowerCase().contains(_searchQuery));
        return poMatch || supplierMatch || siteMatch || itemMatch;
      }

      return true;
    }).toList();
  }

  void _openOrderDetail(ProcurementOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderDetailSheet(
        order: order,
        onUpdateOrder: (updated) {
          setState(() {
            final idx = _orders.indexWhere((o) => o.id == updated.id);
            if (idx != -1) {
              _orders[idx] = updated;
            }
          });
        },
      ),
    );
  }

  void _openCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CreateOrderModal(
        onOrderCreated: (newOrder) {
          setState(() {
            _orders.insert(0, newOrder);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Created ${newOrder.poNumber}. Progressing to Finance & Supplier stage.'),
              backgroundColor: AppColors.darkText,
            ),
          );
        },
      ),
    );
  }

  void _openWorkflowDiagram([ProcurementWorkflowStage? stage]) {
    showDialog(
      context: context,
      builder: (ctx) => WorkflowDiagramDialog(activeStage: stage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.emeraldAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'MOD-06',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emeraldAccent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Material Tracking',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Flowchart Workflow',
            icon: const Icon(Icons.account_tree_outlined,
                color: AppColors.darkText),
            onPressed: () => _openWorkflowDiagram(),
          ),
          Builder(
            builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 500;
              if (isMobile) {
                return IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.teal),
                  tooltip: 'New PO Order',
                  onPressed: _openCreateOrderDialog,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ElevatedButton.icon(
                  onPressed: _openCreateOrderDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New PO Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pipeline Overview & Lifecycle Metrics
                WorkflowPipelineWidget(
                  orders: _orders,
                  onViewDiagram: () => _openWorkflowDiagram(),
                ),

                const SizedBox(height: 24),

                // 2. Search & Filter Bar
                _buildSearchAndFilters(),

                const SizedBox(height: 16),

                // 3. Procurement Orders List
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return _buildOrderCard(order);
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(roleName: widget.roleName),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search TextField
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'Search orders by PO number, supplier, location, or material...',
              hintStyle:
                  const TextStyle(fontSize: 13.5, color: AppColors.textSubtle),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Filter Chips Horizontal Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = index);
                  },
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.darkText,
                  ),
                  selectedColor: AppColors.teal,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.teal : AppColors.borderLight,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(ProcurementOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openOrderDetail(order),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: PO Number + Stage Badge (Adaptive Wrap)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.poNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            order.id,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.stage.badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: order.stage.badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: Text(
                              order.stage.displayName,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: order.stage.badgeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Supplier & Location
                Row(
                  children: [
                    const Icon(Icons.business_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.supplierName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.place_outlined,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      order.projectSite,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Items summary snippet
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.items.map((i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '• ${i.itemName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            Text(
                              '${i.orderedQuantity} ${i.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Footer row: calendar flags, delivery date, Action button (Mobile Adaptive Wrap)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (order.isCalendarNotified) ...[
                          const Icon(Icons.event_available_rounded,
                              size: 15, color: AppColors.teal),
                          const SizedBox(width: 4),
                          const Text(
                            'Calendar Synced',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (order.confirmedDeliveryDate != null)
                          Text(
                            'Deliv: ${_formatDate(order.confirmedDeliveryDate!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Execute Step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: order.stage.badgeColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: order.stage.badgeColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No matching procurement orders',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your search query or selected lifecycle filter.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}


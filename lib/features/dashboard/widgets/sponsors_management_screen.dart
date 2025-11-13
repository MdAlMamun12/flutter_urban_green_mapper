import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';
import 'package:urban_green_mapper/features/dashboard/utils/dashboard_colors.dart';

class SponsorsManagementScreen extends StatefulWidget {
  const SponsorsManagementScreen({super.key});

  @override
  State<SponsorsManagementScreen> createState() => _SponsorsManagementScreenState();
}

class _SponsorsManagementScreenState extends State<SponsorsManagementScreen> {
  final _searchController = TextEditingController();
  String _filterTier = 'all';
  final List<String> _tiers = ['all', 'bronze', 'silver', 'gold', 'platinum'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NGODashboardProvider>(context, listen: false);
      provider.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<NGODashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsors Management'),
        backgroundColor: DashboardColors.safeGreen(700),
        foregroundColor: DashboardColors.primaryWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewSponsor(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: dashboardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSponsorsList(dashboardProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search sponsors',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterSponsors();
                },
              ),
            ),
            onChanged: (value) => _filterSponsors(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _tiers.map((tier) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      tier == 'all' ? 'All' : tier.toUpperCase(),
                      style: TextStyle(
                        color: _filterTier == tier ? DashboardColors.primaryWhite : _getTierColor(tier),
                      ),
                    ),
                    selected: _filterTier == tier,
                    onSelected: (selected) {
                      setState(() {
                        _filterTier = selected ? tier : 'all';
                      });
                      _filterSponsors();
                    },
                    backgroundColor: DashboardColors.safeGrey(200),
                    selectedColor: _getTierColor(tier),
                    checkmarkColor: DashboardColors.primaryWhite,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsList(NGODashboardProvider provider) {
    final filteredSponsors = _getFilteredSponsors(provider.sponsors);

    if (filteredSponsors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSponsors.length,
      itemBuilder: (context, index) {
        final sponsor = filteredSponsors[index];
        return _buildSponsorCard(sponsor);
      },
    );
  }

  Widget _buildSponsorCard(SponsorModel sponsor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showSponsorDetails(sponsor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTierColor(sponsor.tier).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getTierColor(sponsor.tier),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.business,
                  color: _getTierColor(sponsor.tier),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor.name,
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(sponsor.contactEmail),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTierColor(sponsor.tier).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            sponsor.tier.toUpperCase(),
                            style: TextStyle(
                              color: _getTierColor(sponsor.tier),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${sponsor.totalContribution.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DashboardColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editSponsor(sponsor),
                  ),
                  IconButton(
                    icon: Icon(
                      sponsor.isActive ? Icons.toggle_on : Icons.toggle_off,
                      size: 20,
                      color: sponsor.isActive ? DashboardColors.primaryGreen : DashboardColors.primaryGrey,
                    ),
                    onPressed: () => _toggleSponsorStatus(sponsor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 64, color: DashboardColors.safeGrey(400)),
          const SizedBox(height: 16),
          Text(
            'No sponsors found',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: DashboardColors.safeGrey(600),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first sponsor to start building partnerships',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: DashboardColors.safeGrey(500),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _addNewSponsor,
            child: const Text('Add First Sponsor'),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'platinum':
        return DashboardColors.tierPlatinum;
      case 'gold':
        return DashboardColors.tierGold;
      case 'silver':
        return DashboardColors.tierSilver;
      case 'bronze':
        return DashboardColors.tierBronze;
      default:
        return DashboardColors.primaryGreen;
    }
  }

  List<SponsorModel> _getFilteredSponsors(List<SponsorModel> sponsors) {
    var filtered = sponsors;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((sponsor) {
        return sponsor.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            sponsor.contactEmail.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Filter by tier
    if (_filterTier != 'all') {
      filtered = filtered.where((sponsor) => sponsor.tier == _filterTier).toList();
    }

    return filtered;
  }

  void _filterSponsors() {
    setState(() {});
  }

  void _addNewSponsor() {
    showDialog(
      context: context,
      builder: (context) => AddSponsorDialog(
        onSponsorAdded: () {
          final provider = Provider.of<NGODashboardProvider>(context, listen: false);
          provider.loadDashboardData();
        },
      ),
    );
  }

  void _editSponsor(SponsorModel sponsor) {
    showDialog(
      context: context,
      builder: (context) => AddSponsorDialog(
        sponsor: sponsor,
        onSponsorAdded: () {
          final provider = Provider.of<NGODashboardProvider>(context, listen: false);
          provider.loadDashboardData();
        },
      ),
    );
  }

  void _toggleSponsorStatus(SponsorModel sponsor) {
    final provider = Provider.of<NGODashboardProvider>(context, listen: false);
    provider.manageSponsorStatus(sponsor.sponsorId, !sponsor.isActive);
  }

  void _showSponsorDetails(SponsorModel sponsor) {
    showDialog(
      context: context,
      builder: (context) => SponsorDetailsDialog(sponsor: sponsor),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddSponsorDialog extends StatefulWidget {
  final SponsorModel? sponsor;
  final VoidCallback onSponsorAdded;

  const AddSponsorDialog({
    super.key,
    this.sponsor,
    required this.onSponsorAdded,
  });

  @override
  State<AddSponsorDialog> createState() => _AddSponsorDialogState();
}

class _AddSponsorDialogState extends State<AddSponsorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTier = 'bronze';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.sponsor != null) {
      _nameController.text = widget.sponsor!.name;
      _emailController.text = widget.sponsor!.contactEmail;
      _phoneController.text = widget.sponsor!.phoneNumber ?? '';
      _websiteController.text = widget.sponsor!.website ?? '';
      _addressController.text = widget.sponsor!.address ?? '';
      _descriptionController.text = widget.sponsor!.description ?? '';
      _selectedTier = widget.sponsor!.tier;
      _isActive = widget.sponsor!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sponsor == null ? 'Add New Sponsor' : 'Edit Sponsor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Sponsor Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sponsor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTier,
                decoration: const InputDecoration(
                  labelText: 'Sponsor Tier',
                  border: OutlineInputBorder(),
                ),
                items: ['bronze', 'silver', 'gold', 'platinum'].map((tier) {
                  return DropdownMenuItem(
                    value: tier,
                    child: Text(tier.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTier = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value!;
                      });
                    },
                  ),
                  const Text('Active Sponsor'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSponsor,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveSponsor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = Provider.of<NGODashboardProvider>(context, listen: false);
        
        final sponsor = SponsorModel(
          sponsorId: widget.sponsor?.sponsorId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          contactEmail: _emailController.text.trim(),
          tier: _selectedTier,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          totalContribution: widget.sponsor?.totalContribution ?? 0.0,
          sponsoredEventsCount: widget.sponsor?.sponsoredEventsCount ?? 0,
          joinedAt: widget.sponsor?.joinedAt ?? DateTime.now(),
          isActive: _isActive,
          sponsoredEvents: widget.sponsor?.sponsoredEvents ?? [],
        );

        if (widget.sponsor == null) {
          await provider.addSponsor(sponsor);
        } else {
          await provider.updateSponsor(sponsor);
        }

        widget.onSponsorAdded();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.sponsor == null ? 'Sponsor added successfully!' : 'Sponsor updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save sponsor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class SponsorDetailsDialog extends StatelessWidget {
  final SponsorModel sponsor;

  const SponsorDetailsDialog({super.key, required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(sponsor.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailItem('Email', sponsor.contactEmail),
            if (sponsor.phoneNumber != null) _buildDetailItem('Phone', sponsor.phoneNumber!),
            if (sponsor.website != null) _buildDetailItem('Website', sponsor.website!),
            if (sponsor.address != null) _buildDetailItem('Address', sponsor.address!),
            if (sponsor.description != null) _buildDetailItem('Description', sponsor.description!),
            _buildDetailItem('Tier', sponsor.tier.toUpperCase()),
            _buildDetailItem('Total Contribution', '\$${sponsor.totalContribution.toStringAsFixed(2)}'),
            _buildDetailItem('Sponsored Events', sponsor.sponsoredEventsCount.toString()),
            _buildDetailItem('Status', sponsor.isActive ? 'Active' : 'Inactive'),
            _buildDetailItem('Joined', _formatDate(sponsor.joinedAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
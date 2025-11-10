import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

class SponsorRegistrationScreen extends StatefulWidget {
  final bool isUpgradeFromCitizen;

  const SponsorRegistrationScreen({
    super.key,
    this.isUpgradeFromCitizen = false,
  });

  @override
  State<SponsorRegistrationScreen> createState() => _SponsorRegistrationScreenState();
}

class _SponsorRegistrationScreenState extends State<SponsorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizationNameController = TextEditingController();
  final _organizationTypeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedTier = 'bronze';
  final List<String> _tiers = ['bronze', 'silver', 'gold', 'platinum'];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // ignore: unused_local_variable
    final currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpgradeFromCitizen ? 'Become a Sponsor' : 'Sponsor Registration'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isUpgradeFromCitizen) ...[
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You are upgrading your account to become a sponsor while keeping your citizen profile.',
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Text(
                'Organization Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _organizationNameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _organizationTypeController,
                decoration: const InputDecoration(
                  labelText: 'Organization Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'e.g., Corporation, Small Business, Foundation',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter organization type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact person name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              Text(
                'Sponsorship Tier',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedTier,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                items: _tiers.map((tier) {
                  return DropdownMenuItem(
                    value: tier,
                    child: Text(
                      tier.toUpperCase(),
                      style: TextStyle(
                        color: _getTierColor(tier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTier = value!;
                  });
                },
              ),
              const SizedBox(height: 8),

              _buildTierInfo(_selectedTier),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registerAsSponsor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          widget.isUpgradeFromCitizen ? 'Become Sponsor' : 'Register as Sponsor',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierInfo(String tier) {
    final Map<String, Map<String, dynamic>> tierInfo = {
      'bronze': {
        'min_amount': 100.0,
        'benefits': ['Logo on website', 'Social media mention'],
        'color': Colors.brown,
      },
      'silver': {
        'min_amount': 500.0,
        'benefits': ['All Bronze benefits', 'Event signage', 'Newsletter feature'],
        'color': Colors.grey,
      },
      'gold': {
        'min_amount': 1000.0,
        'benefits': ['All Silver benefits', 'Featured on app', 'Press releases'],
        'color': Colors.amber,
      },
      'platinum': {
        'min_amount': 5000.0,
        'benefits': ['All Gold benefits', 'Naming rights', 'Executive meetings'],
        'color': Colors.blue,
      },
    };

    final info = tierInfo[tier]!;

    return Card(
      color: info['color'].withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: info['color']),
                const SizedBox(width: 8),
                Text(
                  '${tier.toUpperCase()} TIER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: info['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Minimum Contribution: \$${info['min_amount']}'),
            const SizedBox(height: 8),
            const Text('Benefits:'),
            ...(info['benefits'] as List<String>).map((benefit) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('• $benefit'),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _registerAsSponsor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.user;

        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        // Create SponsorModel
        final sponsor = SponsorModel(
          sponsorId: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _organizationNameController.text.trim(),
          contactEmail: currentUser.email,
          tier: _selectedTier,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          description: '${_organizationTypeController.text.trim()} - ${_contactPersonController.text.trim()}',
          totalContribution: 0.0,
          sponsoredEventsCount: 0,
          joinedAt: DateTime.now(),
          isActive: true,
          sponsoredEvents: [],
          contactPerson: {
            'name': _contactPersonController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': currentUser.email,
          },
        );

        // Save sponsor to Firestore using DatabaseService
        final databaseService = DatabaseService();
        await databaseService.addSponsor(sponsor);

        // If upgrading from citizen, also update user role
        if (widget.isUpgradeFromCitizen) {
          await databaseService.upgradeUserToSponsor(
            userId: currentUser.userId,
            organizationName: _organizationNameController.text.trim(),
            organizationType: _organizationTypeController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            sponsorTier: _selectedTier,
            website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
            businessAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isUpgradeFromCitizen 
                  ? 'Successfully registered as a sponsor!'
                  : 'Sponsor registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back
          Navigator.pop(context);
        }

      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _organizationTypeController.dispose();
    _websiteController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onPasswordChange;
  final Function(String? email, String? phoneNumber, String? otp, String? newPassword) onPasswordReset;

  const ChangePasswordDialog({
    super.key,
    required this.onPasswordChange,
    required this.onPasswordReset,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isResettingPassword = false;
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: _isResettingPassword ? _buildResetPasswordForm() : _buildChangePasswordForm(),
      ),
      actions: [
        if (!_isResettingPassword) ...[
          TextButton(
            onPressed: () {
              setState(() {
                _isResettingPassword = true;
              });
            },
            child: const Text('Forgot Password?'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            onPressed: _changePassword,
            child: const Text('Change Password'),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              setState(() {
                _isResettingPassword = false;
                _otpSent = false;
              });
            },
            child: const Text('Back to Login'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            onPressed: _otpSent ? _verifyOtpAndReset : _sendResetOtp,
            child: Text(_otpSent ? 'Reset Password' : 'Send OTP'),
          ),
        ],
      ],
    );
  }

  Widget _buildChangePasswordForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _currentPasswordController,
          decoration: InputDecoration(
            labelText: 'Current Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _showCurrentPassword = !_showCurrentPassword;
                });
              },
            ),
          ),
          obscureText: !_showCurrentPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter current password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
            ),
          ),
          obscureText: !_showNewPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter new password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
          ),
          obscureText: !_showConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm new password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reset your password using email or phone number',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        const Text('OR', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          enabled: !_otpSent,
        ),
        if (_otpSent) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'OTP Code',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
              ),
            ),
            obscureText: !_showNewPassword,
          ),
        ],
      ],
    );
  }

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    widget.onPasswordChange(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
  }

  void _sendResetOtp() {
    if (_emailController.text.isEmpty && _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email or phone number')),
      );
      return;
    }

    if (_phoneController.text.isNotEmpty) {
      // Send OTP to phone
      setState(() {
        _otpSent = true;
      });
      widget.onPasswordReset(null, _phoneController.text, null, null);
    } else {
      // Send reset email
      widget.onPasswordReset(_emailController.text, null, null, null);
    }
  }

  void _verifyOtpAndReset() {
    if (_otpController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP and new password')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    widget.onPasswordReset(
      null,
      _phoneController.text,
      _otpController.text,
      _newPasswordController.text,
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
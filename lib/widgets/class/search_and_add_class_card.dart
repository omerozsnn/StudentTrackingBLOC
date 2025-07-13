import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class SearchAndAddClassCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onAdd;
  final FocusNode focusNode;

  const SearchAndAddClassCard({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onAdd,
    required this.focusNode,
  });

  @override
  _SearchAndAddClassCardState createState() => _SearchAndAddClassCardState();
}

class _SearchAndAddClassCardState extends State<SearchAndAddClassCard> {
  bool _isAddMode = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateMode);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateMode);
    super.dispose();
  }

  void _updateMode() {
    final text = widget.controller.text;
    final isAddPattern = RegExp(r'^\d+\s*[A-Za-z]$').hasMatch(text);
    if (isAddPattern != _isAddMode) {
      setState(() {
        _isAddMode = isAddPattern;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = widget.controller.text.isNotEmpty;

    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  _isAddMode ? Icons.add_box_outlined : Icons.search,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Sınıf ara veya ekle... (Örn: 6 A, 7 B)',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Ara',
                onPressed: hasText ? widget.onSearch : null,
                color: AppColors.accent,
                icon: Icons.search,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Ekle',
                onPressed: hasText ? widget.onAdd : null,
                color: AppColors.secondary,
                icon: Icons.add,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoBar(),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF3498DB), width: 4),
        ),
      ),
      child: Row(
        children: [
          const Text("💡", style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isAddMode
                  ? 'Bu sınıfı eklemek için "Ekle" butonuna basın.'
                  : 'Aramak için sınıf adını yazın ve "Ara"ya tıklayın.',
              style: TextStyle(color: AppColors.secondary.withOpacity(0.9), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
} 